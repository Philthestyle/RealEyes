//
//  DIContainer.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation

/// Dependency Injection Container
/// Manages service registration and resolution throughout the app
/// Uses type-safe approach with String keys based on type names
final class DIContainer {
    // MARK: - Singleton
    
    static let shared = DIContainer()
    
    // MARK: - Private Properties
    
    private var services: [String: Any] = [:]
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Registers a service in the container
    /// - Parameter service: The service instance to register
    func register<T>(_ service: T) {
        let key = String(describing: T.self)
        services[key] = service
    }
    
    /// Resolves a service from the container
    /// - Returns: The requested service if found, nil otherwise
    func resolve<T>() -> T? {
        let key = String(describing: T.self)
        return services[key] as? T
    }
}
