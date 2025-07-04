//
//  DIContainer.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation

// MARK: - Service Locator Protocol
protocol ServiceLocator {
    func register<T>(_ type: T.Type, factory: @escaping () -> T)
    func register<T>(_ service: T)
    func resolve<T>() -> T
}

// MARK: - Dependency Injection Container
public final class DIContainer: ServiceLocator {
    public static let shared = DIContainer()
    
    private var services: [String: Any] = [:]
    private let queue = DispatchQueue(label: "com.app.dicontainer", attributes: .concurrent)
    
    public init() {}
    
    // MARK: - Register with factory
    public func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        queue.async(flags: .barrier) {
            self.services[key] = factory
        }
    }
    
    // MARK: - Register singleton instance
    public func register<T>(_ service: T) {
        let key = String(describing: T.self)
        queue.async(flags: .barrier) {
            self.services[key] = service
        }
    }
    
    // MARK: - Resolve service
    public func resolve<T>() -> T {
        let key = String(describing: T.self)
        
        return queue.sync {
            if let service = services[key] as? T {
                return service
            } else if let factory = services[key] as? () -> T {
                return factory()
            } else {
                fatalError("⚠️ Service \(T.self) not registered in DI Container")
            }
        }
    }
    
    // MARK: - Optional resolve
    public func resolveOptional<T>() -> T? {
        let key = String(describing: T.self)
        
        return queue.sync {
            if let service = services[key] as? T {
                return service
            } else if let factory = services[key] as? () -> T {
                return factory()
            }
            return nil
        }
    }
    
    // MARK: - Clear all services (useful for tests)
    public func reset() {
        queue.async(flags: .barrier) {
            self.services.removeAll()
        }
    }
}

// MARK: - Property Wrapper for Dependency Injection
@propertyWrapper
struct Injected<T> {
    private let container = DIContainer.shared
    
    var wrappedValue: T {
        container.resolve()
    }
}

// MARK: - Optional Injection
@propertyWrapper
struct OptionalInjected<T> {
    private let container = DIContainer.shared
    
    var wrappedValue: T? {
        container.resolveOptional()
    }
}
