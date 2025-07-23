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
    
    
    // MEMORY Mointro
    @StateObject private var memoryMonitor = MemoryMonitor()
    
    init() {
        // INITIALISATION DE L'APP
        // Ordre important : DI avant appearance
        // DI peut être utilisé dans appearance config
        setupDependencies()
        setupAppearance()
        print("🚀 [RealEyes] Memory monitoring started...")
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
        
        // NETWORK SERVICE - SINGLETON
        // Partagé dans toute l'app (URLSession est thread-safe)
        // Évite de créer plusieurs sessions HTTP
        container.register(NetworkService.shared)
        
        // SERVICES - FACTORY PATTERN
        // Nouvelle instance à chaque resolve()
        // Permet d'avoir des états indépendants
        //
        // DOUBLE ENREGISTREMENT (Protocol + Concrete):
        // - Protocol pour l'injection dans les ViewModels (abstraction)
        // - Concrete pour les cas spécifiques (tests, debug)
        container.register(StoryServiceProtocol.self) { StoryService() }
        container.register(PostServiceProtocol.self) { PostService() }
        
        container.register(StoryService.self) { StoryService() }
        container.register(PostService.self) { PostService() }
        
        // PROFILE MANAGER - SINGLETON
        // Gère l'image de profil unique de l'utilisateur
        // Doit persister pendant toute la session
        container.register(ProfileImageManager.shared)
        
        print("✅ Dependencies registered:")
        print("   - NetworkService (Singleton)")
        print("   - StoryService")
        print("   - PostService")
        print("   - ProfileImageManager")
    }
    
    // MARK: - Setup Appearance
    private func setupAppearance() {
        // NAVIGATION BAR CONFIGURATION
        // Style Instagram : fond blanc/noir selon le mode, pas d'ombre
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = .systemBackground  // Adaptatif light/dark
        navAppearance.shadowColor = .clear  // Pas de ligne de séparation
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        
        // TAB BAR CONFIGURATION
        // Style Instagram : fond opaque, ligne de séparation subtile
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = .systemBackground
        tabAppearance.shadowColor = .separator  // Ligne subtile en haut
        
        // Configure item appearance
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = .label
        itemAppearance.selected.iconColor = .label
        
        tabAppearance.stackedLayoutAppearance = itemAppearance
        tabAppearance.inlineLayoutAppearance = itemAppearance
        tabAppearance.compactInlineLayoutAppearance = itemAppearance
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        
        // REMOVE TAB TITLES - INSTAGRAM STYLE
        // Instagram n'affiche que les icônes, pas de texte
        // Trick : police taille 0.1 (invisible mais présente pour VoiceOver)
        // Alternative : titlePositionAdjustment mais moins fiable
        UITabBarItem.appearance().setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 0.1)
        ], for: .normal)
        
        print("✅ UI Appearance configured")
    }
}
