//
//  RealEyesApp.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI

@main
struct RealEyesApp: App {
    @StateObject private var profileManager = ProfileImageManager.shared
    @State private var showProfileSetup = false
    @State private var showLaunchScreen = true
    
    init() {
        setupDependencies()
        setupAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .onAppear {
                        checkProfileSetup()
                        print("✅ Instagram Stories Clone - App launched successfully")
                    }
                    .sheet(isPresented: $showProfileSetup) {
                        ProfileImageSetupView()
                    }
                
                // Launch Screen overlay
                if showLaunchScreen {
                    LaunchScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                        .onAppear {
                            // Hide launch screen after 2 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    showLaunchScreen = false
                                }
                            }
                        }
                }
            }
        }
    }
    
    private func checkProfileSetup() {
        // Show profile setup on first launch
        if !profileManager.hasProfileImage {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showProfileSetup = true
            }
        }
    }
    
    // MARK: - Setup Dependencies
    private func setupDependencies() {
        let container = DIContainer.shared
        
        // Register Network Service (Singleton)
        container.register(NetworkService.shared)
        
        // Register Services
        container.register(StoryServiceProtocol.self) { StoryService() }
        container.register(PostServiceProtocol.self) { PostService() }
        
        // For convenience, also register concrete types
        container.register(StoryService.self) { StoryService() }
        container.register(PostService.self) { PostService() }
        
        // Register ProfileImageManager as singleton
        container.register(ProfileImageManager.shared)
        
        print("✅ Dependencies registered:")
        print("   - NetworkService (Singleton)")
        print("   - StoryService")
        print("   - PostService")
        print("   - ProfileImageManager")
    }
    
    // MARK: - Setup Appearance
    private func setupAppearance() {
        // Navigation Bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = .systemBackground
        navAppearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        
        // Tab Bar
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = .systemBackground
        tabAppearance.shadowColor = .separator
        
        // Configure item appearance
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = .label
        itemAppearance.selected.iconColor = .label
        
        tabAppearance.stackedLayoutAppearance = itemAppearance
        tabAppearance.inlineLayoutAppearance = itemAppearance
        tabAppearance.compactInlineLayoutAppearance = itemAppearance
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        
        // Remove tab titles (Instagram style)
        UITabBarItem.appearance().setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 0.1)
        ], for: .normal)
        
        print("✅ UI Appearance configured")
    }
}
