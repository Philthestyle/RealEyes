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
        
        // Start loading immediately
        Task {
            await loadData()
        }
    }
    
    // MARK: - Public Methods
    func loadData() async {
        print("\n🏠 [HomeViewModel] Starting concurrent data loading with TaskGroup...")
        print("⚡ [HomeViewModel] Loading Stories and Posts in PARALLEL for better performance")
        
        if !hasInitiallyLoaded {
            // Initial load - show loading states
            storiesState = .loading
            postsState = .loading
        }
        
        isRefreshing = true
        let startTime = Date()
        
        // Load both concurrently
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
        
        // Ensure minimum loading time for smooth transition
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
        
        // Update service first
        storyService.markAsSeen(story.id)
        
        // Get updated stories from service to ensure consistency
        let updatedStories = storyService.stories
        
        // Update state with animation for smooth UI update
        withAnimation(.easeInOut(duration: 0.3)) {
            storiesState = .loaded(updatedStories)
        }
        
        // Debug: Check if update worked
        if let updatedStory = updatedStories.first(where: { $0.id == story.id }) {
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
