//
//  StoryService.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation


// MARK: - Story Service Implementation
final class StoryService: StoryServiceProtocol {
    private let networkService: NetworkService
    private(set) var stories: [StoryGroup] = []
    
    private let mockDataProvider = MockDataProvider.shared
    
    // UserDefaults key for seen stories
    private let seenStoriesKey = "com.realeyes.seenStories"
    private var seenStoryIds: Set<String> {
        get {
            let array = UserDefaults.standard.stringArray(forKey: seenStoriesKey) ?? []
            return Set(array)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: seenStoriesKey)
        }
    }
    
    init() {
        self.networkService = DIContainer.shared.resolveOptional() ?? NetworkService.shared
    }
    
    func loadStories() async throws {
        print("\n📱 [StoryService] Starting to load stories...")
        print("🌐 [StoryService] Attempting to fetch from API: \(APIEndpoints.users)?limit=10")
        
        do {
            // Try to fetch users from API
            let response = try await self.networkService.fetch(
                UsersResponse.self,
                from: "\(APIEndpoints.users)?limit=10"
            )
            
            print("✅ [StoryService] API SUCCESS! Fetched \(response.users.count) users from dummyjson.com")
            print("👥 [StoryService] Users fetched: \(response.users.map { $0.username }.joined(separator: ", "))")
            
            stories = MockStories.generateStoryGroups(for: response)
            print("🎨 [StoryService] Enhanced API data with high-quality images from Unsplash")
            print("📸 [StoryService] Created \(stories.count) story groups with \(stories.map { $0.stories.count }.reduce(0, +)) total stories")
            
            // Restore seen state from UserDefaults
            let seenIds = seenStoryIds
            var restoredCount = 0
            for index in stories.indices {
                if seenIds.contains(stories[index].id.uuidString) {
                    stories[index].hasBeenSeen = true
                    restoredCount += 1
                }
            }
            if restoredCount > 0 {
                print("💾 [StoryService] Restored \(restoredCount) seen states from UserDefaults")
            }
            
        } catch {
            // Fallback to high-quality mock data
            print("❌ [StoryService] API FAILED! Error: \(error.localizedDescription)")
            print("🔄 [StoryService] Switching to mock data fallback...")
            loadMockStories()
            print("✅ [StoryService] Successfully loaded \(stories.count) mock stories")
        }
        
        print("✨ [StoryService] Story loading complete!\n")
    }
    
    // MARK: Update methods
    func markAsSeen(_ storyId: UUID) {
        if let index = stories.firstIndex(where: { $0.id == storyId }) {
            stories[index].hasBeenSeen = true
            
            // Persist to UserDefaults
            var currentSeenIds = seenStoryIds
            currentSeenIds.insert(storyId.uuidString)
            seenStoryIds = currentSeenIds
        }
    }
    
    func loadMockStories() {
        stories = mockDataProvider.generateMockStories()
        
        // IMPORTANT: Restore seen state from UserDefaults for mock stories too!
        let seenIds = seenStoryIds
        for index in stories.indices {
            if seenIds.contains(stories[index].id.uuidString) {
                stories[index].hasBeenSeen = true
            }
        }
    }
}
