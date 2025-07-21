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
            
        } catch {
            // Fallback to high-quality mock data
            print("❌ [StoryService] API FAILED! Error: \(error.localizedDescription)")
            print("🔄 [StoryService] Switching to mock data fallback...")
            loadMockStories()
            print("✅ [StoryService] Successfully loaded \(stories.count) mock stories")
        }
        
        print("✨ [StoryService] Story loading complete!\n")
    }
    
    // ✅ FIX: Utiliser SessionDataCache pour la persistance
    func markAsSeen(_ storyId: String) {
        if let index = stories.firstIndex(where: { $0.id == storyId }) {
            stories[index].hasBeenSeen = true
            
            // 🎯 Utiliser SessionDataCache au lieu du système local
            SessionDataCache.shared.markStoryAsSeen(storyId)
            
            print("🎯 Story marked as seen via SessionDataCache: \(storyId)")
        }
    }
    
    func loadMockStories() {
        stories = mockDataProvider.generateMockStories()
        
        // ✅ FIX: Appliquer les états "vus" depuis SessionDataCache
        for index in stories.indices {
            let storyId = stories[index].id
            if SessionDataCache.shared.isStorySeen(storyId) {
                stories[index].hasBeenSeen = true
            }
        }
        
        print("💾 [StoryService] Applied seen states from SessionDataCache")
    }
}