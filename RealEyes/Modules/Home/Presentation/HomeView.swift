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
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Header
            instagramHeader
            
            // Content with refresh
            ScrollView {
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
                await viewModel.loadData()
            }
        }
    }
    
    // MARK: - Header
    private var instagramHeader: some View {
        HStack {
            HStack(alignment: .top, spacing: -5) {
                let realGradient = LinearGradient(
                    colors: [
                        Color(red: 0.96, green: 0.36, blue: 0.22),
                        Color(red: 0.87, green: 0.16, blue: 0.50),
                        Color(red: 0.51, green: 0.20, blue: 0.69),
                        Color(red: 0.32, green: 0.36, blue: 0.83)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                
                let eyesGradient = LinearGradient(
                    colors: [
                        Color(red: 0.96, green: 0.36, blue: 0.22),
                        Color(red: 0.87, green: 0.16, blue: 0.50),
                        Color(red: 0.51, green: 0.20, blue: 0.69),
                        Color(red: 0.32, green: 0.36, blue: 0.83)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                
                Text("Real")
                    .foregroundStyle(realGradient)
                
                Text("Eyes")
                    .foregroundStyle(eyesGradient)
            }
            .font(.system(size: 36, weight: .bold, design: .rounded))
            
            
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
                    currentStoryId = storyGroup.id.uuidString
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
}
