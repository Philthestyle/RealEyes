//
//  HomeViewModel.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

//
//  HomeViewModel.swift
//  InstagramStoriesClone
//
//  Created by DevTeam on 30/06/2025.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel principal de l'écran Home
/// Coordonne le chargement des stories et posts
/// 
/// ARCHITECTURE DECISION:
/// - Un seul ViewModel pour l'écran entier (pas de sur-décomposition)
/// - Gère plusieurs sources de données (stories + posts)
/// - Utilise TaskGroup pour le chargement parallèle
@MainActor
final class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var storiesState: ViewState<[StoryGroup]> = .idle
    @Published private(set) var postsState: ViewState<[Post]> = .idle
    @Published private(set) var isRefreshing = false
    
    // MARK: - Dependencies
    private let storyService: StoryService
    private let postService: PostService
    
    // MARK: - Properties
    private let minimumLoadingDuration: TimeInterval = 1.0
    private var hasInitiallyLoaded = false
    
    // MARK: - Computed Properties
    var storyGroups: [StoryGroup] {
        storiesState.data ?? []
    }
    
    var posts: [Post] {
        postsState.data ?? []
    }
    
    var isInitialLoading: Bool {
        !hasInitiallyLoaded && storiesState.isLoading && postsState.isLoading
    }
    
    // MARK: - Initialization
    init() {
        self.storyService = DIContainer.shared.resolveOptional() ?? StoryService()
        self.postService = DIContainer.shared.resolveOptional() ?? PostService()
        
        // CHARGEMENT INITIAL AU LANCEMENT
        // Task non structurée car on veut que le chargement continue
        // même si la vue est recréée
        // Alternative: .task {} dans la vue, mais moins fiable
        Task {
            await loadData()
        }
    }
    
    // MARK: - Public Methods
    func loadData() async {
        print("\n🏠 [HomeViewModel] Starting concurrent data loading with TaskGroup...")
        print("⚡ [HomeViewModel] Loading Stories and Posts in PARALLEL for better performance")
        
        // GESTION DES ÉTATS DE CHARGEMENT
        // Seulement au premier chargement pour éviter le flash
        // Pull-to-refresh ne change pas l'état (UX plus smooth)
        if !hasInitiallyLoaded {
            // Initial load - show loading states
            storiesState = .loading
            postsState = .loading
        }
        
        isRefreshing = true
        let startTime = Date()
        
        // TASKGROUP POUR CHARGEMENT CONCURRENT
        // 
        // POURQUOI TASKGROUP vs ASYNC LET ?
        // 1. TaskGroup est extensible (facile d'ajouter d'autres tasks)
        // 2. Meilleur contrôle sur l'annulation
        // 3. Pattern plus clean pour N opérations
        // 4. Gestion d'erreur unifiée possible
        // 
        // POURQUOI [weak self] ?
        // - Évite les retain cycles si la Task survit au ViewModel
        // - Bonne pratique même si @MainActor minimise le risque
        // - Cohérent avec les patterns Combine
        await withTaskGroup(of: Void.self) { group in
            print("🔄 [HomeViewModel] TaskGroup started - launching parallel tasks...")
            
            group.addTask { [weak self] in
                print("📈 [HomeViewModel] Task 1: Loading Stories...")
                await self?.loadStories()
            }
            
            group.addTask { [weak self] in
                print("📈 [HomeViewModel] Task 2: Loading Posts...")
                await self?.loadPosts()
            }
        }
        
        // MINIMUM LOADING TIME
        // Seulement au premier chargement
        // Évite l'effet "flash" si l'API est trop rapide
        // Améliore la perception de qualité
        let elapsed = Date().timeIntervalSince(startTime)
        print("⏱️ [HomeViewModel] Data loaded in \(String(format: "%.2f", elapsed)) seconds")
        
        if elapsed < minimumLoadingDuration && !hasInitiallyLoaded {
            try? await Task.sleep(nanoseconds: UInt64((minimumLoadingDuration - elapsed) * 1_000_000_000))
        }
        
        hasInitiallyLoaded = true
        isRefreshing = false
        
        print("🎉 [HomeViewModel] All data loaded successfully!")
        print("📊 [HomeViewModel] Stories: \(storyGroups.count), Posts: \(posts.count)\n")
    }
    
    func markStoryGroupAsSeen(_ story: StoryGroup) {
        print("🎯 Marking story as seen: \(story.user.username)")
        
        // PATTERN DE MISE À JOUR EN 3 ÉTAPES
        // 
        // 1. SERVICE LAYER (Source de vérité)
        // Persiste l'état dans SessionDataCache/UserDefaults
        storyService.markAsSeen(story.id)
        
        // 2. UI STATE (Réactivité immédiate)
        // Met à jour l'état local pour feedback instantané
        // L'utilisateur voit le changement sans attendre
        if case .loaded(let currentStories) = storiesState {
            let updatedStories = currentStories.map { currentStory in
                if currentStory.id == story.id {
                    var updated = currentStory
                    updated.hasBeenSeen = true
                    return updated
                }
                return currentStory
            }
            
            // ANIMATION SUBTILE
            // Transition smooth du gradient vers gris
            // 0.3s = durée standard iOS
            withAnimation(.easeInOut(duration: 0.3)) {
                storiesState = .loaded(updatedStories)
            }
        }
        
        // 3. VALIDATION (Debug only)
        // Vérifie que l'update a bien été appliqué
        // Utile pour débugger les problèmes de state
        if case .loaded(let stories) = storiesState,
           let updatedStory = stories.first(where: { $0.id == story.id }) {
            print("✅ Story marked as seen: \(updatedStory.user.username) - hasBeenSeen: \(updatedStory.hasBeenSeen)")
        }
    }
    
    // MARK: - Private Methods
    private func loadStories() async {
        do {
            try await storyService.loadStories()
            let stories = storyService.stories
            
            // Use animation only after initial load
            if hasInitiallyLoaded {
                withAnimation(.easeInOut(duration: 0.3)) {
                    storiesState = .loaded(stories)
                }
            } else {
                storiesState = .loaded(stories)
            }
        } catch {
            print("❌ Failed to load stories: \(error)")
            // Use mock data as fallback
            storyService.loadMockStories()
            let mockStories = storyService.stories
            
            if hasInitiallyLoaded {
                withAnimation(.easeInOut(duration: 0.3)) {
                    storiesState = .loaded(mockStories)
                }
            } else {
                storiesState = .loaded(mockStories)
            }
        }
    }
    
    private func loadPosts() async {
        do {
            try await postService.loadPosts()
            let posts = postService.posts
            
            if hasInitiallyLoaded {
                withAnimation(.easeInOut(duration: 0.3)) {
                    postsState = .loaded(posts)
                }
            } else {
                postsState = .loaded(posts)
            }
        } catch {
            print("❌ Failed to load posts: \(error)")
            // Use mock data as fallback
            postService.loadMockPosts()
            let mockPosts = postService.posts
            
            if hasInitiallyLoaded {
                withAnimation(.easeInOut(duration: 0.3)) {
                    postsState = .loaded(mockPosts)
                }
            } else {
                postsState = .loaded(mockPosts)
            }
        }
    }
}
