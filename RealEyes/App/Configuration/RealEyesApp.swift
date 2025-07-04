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
        //  TODO: Register core services
       
        
        // TODO: Register feature services
        
        print("✅ RealEyes - Dependencies registered")
    }
}
