//
//  FeedView.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI

public struct FeedView: View {
    @StateObject private var viewModel: PostsViewModel
    
    public init(viewModel: PostsViewModel? = nil) {
        self._viewModel = StateObject(wrappedValue: viewModel ?? PostsViewModel())
    }
    
    public var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                LoadingView(style: .feed)
                    .transition(.opacity)
                
            case .loaded:
                feedContent
                    .transition(.opacity)
                
            case .error:
                errorView
            }
        }
        .task {
            await viewModel.loadPosts()
        }
    }
    
    // MARK: - Views
    private var feedContent: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.posts) { post in
                    PostView(
                        post: post,
                        onLike: {
                            Task {
                                await viewModel.likePost(post)
                            }
                        },
                        onSave: {
                            Task {
                                await viewModel.savePost(post)
                            }
                        }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 0.5)
                }
                
                // Load more indicator
                if viewModel.isLoadingMore {
                    ProgressView()
                        .padding()
                } else if viewModel.hasMorePosts {
                    Color.clear
                        .frame(height: 1)
                        .onAppear {
                            Task {
                                await viewModel.loadMorePosts()
                            }
                        }
                }
            }
        }
    }
    
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            
            Text("Failed to load posts")
                .font(.headline)
            
            Button("Try Again") {
                Task {
                    await viewModel.loadPosts()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
