//
//  HomeView.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI


struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showStory = false
    @State private var currentStoryId = ""
    @State private var isAnimating = false
    @State private var isRefreshing = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Main content - always visible
                mainContent
                
                // Initial loading overlay
                if viewModel.isInitialLoading {
                    LoadingView(style: .fullScreen, message: "Loading your feed...")
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .navigationBarHidden(true)
            .background(Color(UIColor.systemBackground))
        }
        .fullScreenCover(isPresented: $showStory) {
            storyDetailView
        }
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Header
            instagramHeader
            
            // Content with refresh
            ScrollView {
                // Custom pull to refresh indicator
                if isRefreshing {
                    HStack {
                        Spacer()
                        MiniRainbowLoader()
                            .padding(.top, 10)
                            .padding(.bottom, 20)
                        Spacer()
                    }
                }
                
                VStack(spacing: 0) {
                    // Stories section - adjusted height for bigger circles
                    storiesSection
                        .frame(height: 140) // Increased to match Instagram size
                        .padding(.vertical, 10)
                    
                    Divider()
                    
                    // Feed posts
                    feedContent
                        .padding(.top, 1)
                }
            }
            .refreshable {
                isRefreshing = true
                await viewModel.loadData()
                isRefreshing = false
            }
        }
    }
    
    // MARK: - Header
    private var instagramHeader: some View {
        HStack {
            // Logo RealEyes avec style Instagram
            RealEyesLogoView(height: 100)
            
            Spacer()
            
            HStack(spacing: 24) {
                Button(action: {}) {
                    Image(systemName: "heart")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.primary)
                }
                
                Button(action: {}) {
                    Image(systemName: "paperplane")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.primary)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
    
    // MARK: - Stories Section
    @ViewBuilder
    private var storiesSection: some View {
        switch viewModel.storiesState {
        case .idle, .loading:
            StoriesLoadingSkeleton()
            
        case .loaded(let storyGroups):
            StoriesScrollView(
                stories: storyGroups,
                onStoryTap: { storyGroup in
                    currentStoryId = storyGroup.id
                    showStory = true
                }
            )
            
        case .error:
            VStack {
                Text("Failed to load stories")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button("Retry") {
                    Task {
                        await viewModel.loadData()
                    }
                }
                .font(.caption)
                .buttonStyle(.bordered)
            }
            .padding()
        }
    }
    
    // MARK: - Feed Content
    @ViewBuilder
    private var feedContent: some View {
        LazyVStack(spacing: 0) {
            switch viewModel.postsState {
            case .idle, .loading:
                LoadingView(style: .feed)
                    .padding(.top, 20)
                
            case .loaded(let posts):
                ForEach(posts) { post in
                    PostView(post: post)
                        .padding(.bottom, 20)
                }
                
            case .error:
                ErrorView(
                    title: "Failed to load posts",
                    onRetry: {
                        Task {
                            await viewModel.loadData()
                        }
                    }
                )
                .padding(.top, 40)
            }
        }
    }
    
    // MARK: - Story Detail View
    @ViewBuilder
    private var storyDetailView: some View {
        if case .loaded(_) = viewModel.storiesState {
            StoryDetailView(
                viewModel: viewModel,
                currentStory: $currentStoryId,
                showStory: $showStory,
                isAnimating: $isAnimating
            )
        }
    }
}
