//
//  StoriesViewModel.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI
import Combine

@MainActor
public final class StoriesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var state: ViewState<[StoryGroup]> = .idle
    @Published var selectedStoryId: String = ""
    @Published var showStoryDetail = false
    
    // MARK: - Dependencies
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
        self.storyService = DIContainer.shared.resolveOptional() ?? StoryService()
    }
    
    // MARK: - Public Methods
    func loadStories() async {
        guard !isLoading else { return }
        
        state = .loading
        let startTime = Date()
        
        do {
            try await storyService.loadStories()
            let stories = storyService.stories
            
            // Ensure minimum loading time
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed < minimumLoadingDuration {
                try? await Task.sleep(nanoseconds: UInt64((minimumLoadingDuration - elapsed) * 1_000_000_000))
            }
            
            withAnimation(.easeInOut(duration: 0.3)) {
                state = .loaded(stories)
            }
        } catch {
            print("❌ Failed to load stories: \(error)")
            // Fallback to mock data
            storyService.loadMockStories()
            let mockStories = storyService.stories
            
            withAnimation(.easeInOut(duration: 0.3)) {
                state = .loaded(mockStories)
            }
        }
    }
    
    func selectStory(_ storyGroup: StoryGroup) {
        selectedStoryId = storyGroup.id.uuidString
        showStoryDetail = true
    }
    
    func markStoryAsSeen(_ storyGroup: StoryGroup) {
        storyService.markAsSeen(storyGroup.id)
        
        // Update local state
        if var stories = state.data,
           let index = stories.firstIndex(where: { $0.id == storyGroup.id }) {
            stories[index].hasBeenSeen = true
            state = .loaded(stories)
        }
    }
}
