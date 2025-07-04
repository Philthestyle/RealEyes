//
//  SessionDataCache.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation

// Singleton cache to keep data during the session
class SessionDataCache {
    static let shared = SessionDataCache()
    
    private var cachedStories: [StoryGroup]?
    private var cachedPosts: [Post]?
    private var cachedUsers: [User]?
    
    private init() {}
    
    // Stories
    func getCachedStories() -> [StoryGroup]? {
        return cachedStories
    }
    
    func setCachedStories(_ stories: [StoryGroup]) {
        cachedStories = stories
    }
    
    // Posts
    func getCachedPosts() -> [Post]? {
        return cachedPosts
    }
    
    func setCachedPosts(_ posts: [Post]) {
        cachedPosts = posts
    }
    
    // Users
    func getCachedUsers() -> [User]? {
        return cachedUsers
    }
    
    func setCachedUsers(_ users: [User]) {
        cachedUsers = users
    }
    
    // Clear cache (if needed)
    func clearCache() {
        cachedStories = nil
        cachedPosts = nil
        cachedUsers = nil
    }
}
