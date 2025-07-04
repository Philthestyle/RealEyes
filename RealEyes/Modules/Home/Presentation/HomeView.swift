//
//  HomeView.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI

/// just a simple view for now to have a clean code from start
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
        .fullScreenCover(isPresented: $showStory) {
            //TODO: StoryGroupDetailsView
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
                    // Stories section - adjusted height for bigger circles to be Instagram like
                    storiesSection
                        .frame(height: 140) // Increased to match Instagram size
                        .padding(.vertical, 10)
                    
                    Divider()
                    
                    //TODO: Feed posts
                }
            }
            .refreshable {
                await viewModel.loadData()
            }
        }
    }
    
    // MARK: - Stories Section
    @ViewBuilder
    private var storiesSection: some View {
        switch viewModel.storiesState {
        case .idle, .loading:
            //TODO: implement LoadingView or Skeleton later
                ZStack {
                    // Gradient ring - Instagram size
                    GradientCircle(size: 90, lineWidth: 3.5, isSeen: false)
                    
                    // White border
                    Circle()
                        .fill(Color(UIColor.systemBackground))
                        .frame(width: 82, height: 82)
                    
                    // Grey border for separation
                    Circle()
                        .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
                        .frame(width: 78, height: 78)
                    
                }
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
    
}
