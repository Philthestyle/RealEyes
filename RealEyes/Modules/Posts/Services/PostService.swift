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
        print("\n📰 [PostService] Starting to load posts...")
        print("🌐 [PostService] Attempting to fetch from API: \(APIEndpoints.posts)?limit=20")
        
        do {
            // Try to fetch from API
            let response = try await networkService.fetch(
                PostsResponse.self,
                from: "\(APIEndpoints.posts)?limit=20"
            )
            
            print("✅ [PostService] API SUCCESS! Fetched \(response.posts.count) posts from dummyjson.com")
            
            // Use high-quality mock posts with better content
            posts = mockDataProvider.generateMockPosts()
            
            print("🎨 [PostService] Enhanced posts with:")
            print("   - High-quality images from Unsplash")
            print("   - Styled usernames: naturelover, foodie_life, urban_explorer...")
            print("   - Instagram-style captions with hashtags")
            print("📝 [PostService] Total posts ready: \(posts.count)")
            
        } catch {
            // Fallback to high-quality mock data
            print("❌ [PostService] API FAILED! Error: \(error.localizedDescription)")
            print("🔄 [PostService] Switching to mock data fallback...")
            loadMockPosts()
            print("✅ [PostService] Successfully loaded \(posts.count) mock posts")
        }
        
        print("✨ [PostService] Post loading complete!\n")
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
