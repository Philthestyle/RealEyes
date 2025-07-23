//
//  StoriesViewModel.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI
import Combine

/// ViewModel pour la gestion des Stories
/// 
/// ARCHITECTURE MVVM - POURQUOI CE CHOIX ?
/// 1. Séparation des responsabilités : UI (View) vs Logique (ViewModel)
/// 2. Testabilité : ViewModel testable sans UI
/// 3. Réactivité : @Published + ObservableObject = updates automatiques
/// 4. SwiftUI-friendly : Conçu pour le data binding de SwiftUI
/// 
/// @MainActor - POURQUOI ?
/// - Garantit que toutes les updates UI se font sur le main thread
/// - Évite les race conditions
/// - Simplification du code (pas de DispatchQueue.main partout)
/// - Swift Concurrency best practice
@MainActor
public final class StoriesViewModel: ObservableObject {
    // MARK: - Published Properties
    /// ViewState pattern pour gérer les états de chargement
    /// AVANTAGES:
    /// - Un seul état à observer au lieu de multiples booléens
    /// - Impossible d'être dans un état incohérent
    /// - Générique et réutilisable
    @Published private(set) var state: ViewState<[StoryGroup]> = .idle
    @Published var selectedStoryId: String = ""
    @Published var showStoryDetail = false
    
    // MARK: - Dependencies
    /// Service injecté via DI Container
    /// POURQUOI PAS @Injected ?
    /// - Injection explicite dans l'init pour la clarté
    /// - Possibilité de fallback si le service n'est pas enregistré
    /// - Plus facile à mocker dans les tests
    private let storyService: StoryService
    
    // MARK: - Properties
    private let minimumLoadingDuration: TimeInterval = 0.8
    
    // MARK: - Computed Properties
    var stories: [StoryGroup] {
        state.data ?? []
    }
    
    var isLoading: Bool {
        state.isLoading
    }
    
    // MARK: - Initialization
    public init() {
        // PATTERN D'INJECTION AVEC FALLBACK
        // 1. Tente de résoudre depuis le DI Container
        // 2. Si pas enregistré, crée une instance par défaut
        // AVANTAGE: Évite les crashes si DI mal configuré
        // UTILISATION: Permet les tests sans DI setup
        self.storyService = DIContainer.shared.resolveOptional() ?? StoryService()
    }
    
    // MARK: - Public Methods
    func loadStories() async {
        // GUARD CONTRE LE DOUBLE LOADING
        // Évite les appels multiples pendant le chargement
        guard !isLoading else { return }
        
        state = .loading
        let startTime = Date()
        
        do {
            try await storyService.loadStories()
            let stories = storyService.stories
            
            // MINIMUM LOADING TIME - POURQUOI ?
            // 1. Évite le flash (loading trop rapide = mauvaise UX)
            // 2. Donne l'impression de "travail" à l'app
            // 3. Permet à l'utilisateur de voir le loader (satisfaction)
            // 4. 0.8s = sweet spot (ni trop court, ni trop long)
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed < minimumLoadingDuration {
                try? await Task.sleep(nanoseconds: UInt64((minimumLoadingDuration - elapsed) * 1_000_000_000))
            }
            
            // ANIMATION DE TRANSITION
            // withAnimation pour une transition smooth
            // .easeInOut = accélère puis décélère (naturel)
            // 0.3s = durée standard iOS pour les transitions
            withAnimation(.easeInOut(duration: 0.3)) {
                state = .loaded(stories)
            }
        } catch {
            print("❌ Failed to load stories: \(error)")
            // FALLBACK STRATEGY
            // En cas d'échec réseau, on charge des données mock
            // AVANTAGE: L'app reste utilisable même offline
            // L'utilisateur peut tester les fonctionnalités
            storyService.loadMockStories()
            let mockStories = storyService.stories
            
            withAnimation(.easeInOut(duration: 0.3)) {
                state = .loaded(mockStories)
            }
        }
    }
    
    // MÉTHODE DE SÉLECTION DE STORY
    // Note: Fix appliqué pour utiliser directement l'ID string
    // Avant: on convertissait UUID en string inutilement
    // Maintenant: StoryGroup.id est déjà un String
    func selectStory(_ storyGroup: StoryGroup) {
        selectedStoryId = storyGroup.id
        showStoryDetail = true
    }
    
    func markStoryAsSeen(_ storyGroup: StoryGroup) {
        storyService.markAsSeen(storyGroup.id) // 🎯 Passe directement l'ID string
        
        // Update local state
        if var stories = state.data,
           let index = stories.firstIndex(where: { $0.id == storyGroup.id }) {
            stories[index].hasBeenSeen = true
            state = .loaded(stories)
        }
    }
}