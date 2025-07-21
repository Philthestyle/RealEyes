//
//  SessionDataCache.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation

// ✅ Enhanced cache with real persistence
class SessionDataCache {
    static let shared = SessionDataCache()
    
    private var cachedStories: [StoryGroup]?
    private var cachedPosts: [Post]?
    private var cachedUsers: [User]?
    
    // 🎯 UserDefaults keys for persistence
    private enum Keys {
        static let stories = "cached_stories"
        static let posts = "cached_posts" 
        static let users = "cached_users"
        static let storySeenStates = "story_seen_states"
    }
    
    private init() {}
    
    // MARK: - Stories with persistence
    func getCachedStories() -> [StoryGroup]? {
        // First check memory cache
        if let memoryStories = cachedStories {
            return memoryStories
        }
        
        // Then check UserDefaults
        if let persistedStories = loadStoriesFromDisk() {
            cachedStories = persistedStories
            return persistedStories
        }
        
        return nil
    }
    
    func setCachedStories(_ stories: [StoryGroup]) {
        cachedStories = stories
        persistStoriesToDisk(stories)
    }
    
    // MARK: - Story Seen States Management
    func markStoryAsSeen(_ storyGroupId: String) {
        var seenStates = getSeenStates()
        seenStates[storyGroupId] = true
        setSeenStates(seenStates)
        
        print("💾 [SessionDataCache] Story marked as seen: \(storyGroupId)")
    }
    
    func isStorySeen(_ storyGroupId: String) -> Bool {
        let seenStates = getSeenStates()
        let isSeen = seenStates[storyGroupId] ?? false
        
        if isSeen {
            print("✅ [SessionDataCache] Found SEEN state for: \(storyGroupId)")
        }
        
        return isSeen
    }
    
    private func getSeenStates() -> [String: Bool] {
        let states = UserDefaults.standard.dictionary(forKey: Keys.storySeenStates) as? [String: Bool] ?? [:]
        
        if !states.isEmpty {
            print("💾 [SessionDataCache] Loaded \(states.count) seen states from UserDefaults:")
            for (storyId, seen) in states {
                if seen {
                    print("  ✅ \(storyId): SEEN")
                }
            }
        } else {
            print("💾 [SessionDataCache] No seen states found in UserDefaults")
        }
        
        return states
    }
    
    private func setSeenStates(_ states: [String: Bool]) {
        UserDefaults.standard.set(states, forKey: Keys.storySeenStates)
    }
    
    // MARK: - Disk Persistence
    private func persistStoriesToDisk(_ stories: [StoryGroup]) {
        do {
            let data = try JSONEncoder().encode(stories)
            UserDefaults.standard.set(data, forKey: Keys.stories)
        } catch {
            print("❌ Error persisting stories: \(error)")
        }
    }
    
    private func loadStoriesFromDisk() -> [StoryGroup]? {
        guard let data = UserDefaults.standard.data(forKey: Keys.stories) else { return nil }
        
        do {
            var stories = try JSONDecoder().decode([StoryGroup].self, from: data)
            
            // Apply current seen states
            let seenStates = getSeenStates()
            stories = stories.map { story in
                var updatedStory = story
                updatedStory.hasBeenSeen = seenStates[story.id] ?? story.hasBeenSeen
                return updatedStory
            }
            
            return stories
        } catch {
            print("❌ Error loading stories: \(error)")
            return nil
        }
    }
    
    // MARK: - Posts (existing functionality)
    func getCachedPosts() -> [Post]? {
        return cachedPosts
    }
    
    func setCachedPosts(_ posts: [Post]) {
        cachedPosts = posts
    }
    
    // MARK: - Users (existing functionality)
    func getCachedUsers() -> [User]? {
        return cachedUsers
    }
    
    func setCachedUsers(_ users: [User]) {
        cachedUsers = users
    }
    
    // MARK: - Cache Management
    func clearCache() {
        cachedStories = nil
        cachedPosts = nil
        cachedUsers = nil
    }
    
    func clearPersistentData() {
        UserDefaults.standard.removeObject(forKey: Keys.stories)
        UserDefaults.standard.removeObject(forKey: Keys.storySeenStates)
        clearCache()
        print("🧹 [SessionDataCache] Cleared all persistent data")
    }
    
    // ✅ BONUS: Debug info
    func getDebugInfo() -> String {
        let memoryStories = cachedStories?.count ?? 0
        let seenStatesCount = getSeenStates().count
        let hasPersistedData = UserDefaults.standard.data(forKey: Keys.stories) != nil
        
        return """
        Memory Stories: \(memoryStories)
        Seen States: \(seenStatesCount) 
        Persisted: \(hasPersistedData)
        """
    }
}