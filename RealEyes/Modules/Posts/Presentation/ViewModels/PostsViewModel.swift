//
//  PostsViewModel.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI
import Combine

@MainActor
public final class PostsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var state: ViewState<[Post]> = .idle
    @Published private(set) var isLoadingMore = false
    
    // MARK: - Dependencies
    private let postService: PostService
    
    // MARK: - Properties
    private let minimumLoadingDuration: TimeInterval = 0.8
    private var currentSkip = 0
    private let pageSize = 20
    
    // MARK: - Computed Properties
    var posts: [Post] {
        state.data ?? []
    }
    
    var isLoading: Bool {
        state.isLoading
    }
    
    var hasMorePosts: Bool {
        posts.count >= currentSkip + pageSize
    }
    
    // MARK: - Initialization
    public init() {
        self.postService = DIContainer.shared.resolveOptional() ?? PostService()
    }
    
    // MARK: - Public Methods
    func loadPosts() async {
        guard !isLoading else { return }
        
        state = .loading
        currentSkip = 0
        let startTime = Date()
        
        do {
            try await postService.loadPosts()
            let posts = postService.posts
            
            // Ensure minimum loading time
            let elapsed = Date().timeIntervalSince(startTime)
            if elapsed < minimumLoadingDuration {
                try? await Task.sleep(nanoseconds: UInt64((minimumLoadingDuration - elapsed) * 1_000_000_000))
            }
            
            withAnimation(.easeInOut(duration: 0.3)) {
                state = .loaded(posts)
            }
        } catch {
            print("❌ Failed to load posts: \(error)")
            // Fallback to mock data
            postService.loadMockPosts()
            let mockPosts = postService.posts
            
            withAnimation(.easeInOut(duration: 0.3)) {
                state = .loaded(mockPosts)
            }
        }
    }
    
    func loadMorePosts() async {
        guard !isLoadingMore, hasMorePosts else { return }
        
        isLoadingMore = true
        
        // Simulate loading more posts
        // In a real app, you would fetch more from the API
        await Task.sleep(2_000_000_000) // 2 seconds
        
        isLoadingMore = false
    }
    
    func likePost(_ post: Post) async {
        await postService.likePost(post.id)
    }
    
    func savePost(_ post: Post) async {
        await postService.savePost(post.id)
    }
}
