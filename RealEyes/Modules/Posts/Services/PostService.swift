//
//  PostService.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation

final class PostService: PostServiceProtocol {
    private let networkService: NetworkService
    private let mockDataProvider = MockDataProvider.shared
    private(set) var posts: [Post] = []
    private var likedPosts: Set<Int> = []
    private var savedPosts: Set<Int> = []
    
    init() {
        self.networkService = DIContainer.shared.resolveOptional() ?? NetworkService.shared
    }
    
    func loadPosts() async throws {
        do {
            // Use high-quality mock posts instead of API data
            // This ensures we have beautiful images
            posts = mockDataProvider.generateMockPosts()
        } catch {
            // Fallback to high-quality mock data
            print("Failed to load posts from API, using mock data: \(error)")
            loadMockPosts()
        }
    }
    
    func likePost(_ postId: Int) async {
        if likedPosts.contains(postId) {
            likedPosts.remove(postId)
        } else {
            likedPosts.insert(postId)
        }
        // In real app, sync with backend
        print("Post \(postId) liked: \(likedPosts.contains(postId))")
    }
    
    func savePost(_ postId: Int) async {
        if savedPosts.contains(postId) {
            savedPosts.remove(postId)
        } else {
            savedPosts.insert(postId)
        }
        // In real app, sync with backend
        print("Post \(postId) saved: \(savedPosts.contains(postId))")
    }
    
    func loadMockPosts() {
        posts = mockDataProvider.generateMockPosts()
    }
    
    func isPostLiked(_ postId: Int) -> Bool {
        likedPosts.contains(postId)
    }
    
    func isPostSaved(_ postId: Int) -> Bool {
        savedPosts.contains(postId)
    }
}
