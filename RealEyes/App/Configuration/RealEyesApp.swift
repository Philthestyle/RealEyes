//
//  RealEyesApp.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI

@main
struct RealEyesApp: App {
    // MARK: - Initialization
    
    init() {
        setupDependencies()
    }
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
    
    // MARK: - Private Methods
    
    /// Sets up dependency injection container with all required services
    /// This ensures all dependencies are available before the app starts
    private func setupDependencies() {
        let container = DIContainer.shared
        
        // Core services
        container.register(NetworkService.shared)
        
        // Register feature services
        container.register(StoryServiceProtocol.self) { StoryService() }
        
        print("✅ Dependencies registered")
        print("   - NetworkService (Singleton)")
        print("   - StoryService")
    }
}
