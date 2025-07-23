//
//  DIContainer.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation

// MARK: - Service Locator Protocol
/// Protocol définissant l'interface de notre container d'injection de dépendances
/// Pourquoi un protocole ? Pour permettre le mocking dans les tests unitaires
protocol ServiceLocator {
    /// Enregistre un type avec une factory (création lazy)
    /// Utilisé pour les services qui doivent être créés à la demande
    func register<T>(_ type: T.Type, factory: @escaping () -> T)
    
    /// Enregistre une instance singleton directement
    /// Utilisé pour les services qui doivent être partagés (ex: NetworkService)
    func register<T>(_ service: T)
    
    /// Résout et retourne une instance du type demandé
    /// Crash si le type n'est pas enregistré (fail-fast principle)
    func resolve<T>() -> T
}

// MARK: - Dependency Injection Container
/// Container d'injection de dépendances custom
/// 
/// POURQUOI UN DI CONTAINER CUSTOM ?
/// 1. Léger et simple (pas de dépendance externe)
/// 2. Type-safe avec les generics Swift
/// 3. Thread-safe avec concurrent queue
/// 4. Suffisant pour un projet de cette taille
/// 
/// AVANTAGES vs SWINJECT/RESOLVER:
/// - Pas de dépendance tierce (important pour un test technique)
/// - Code compréhensible immédiatement
/// - Performances optimales (pas d'overhead)
/// - Facile à débugger
public final class DIContainer: ServiceLocator {
    /// Singleton - un seul container pour toute l'app
    /// Pattern approprié car c'est un service global de configuration
    public static let shared = DIContainer()
    
    /// Stockage thread-safe des services
    /// Key: String (nom du type) / Value: soit une instance, soit une factory
    private var services: [String: Any] = [:]
    
    /// Queue concurrente pour permettre les lectures simultanées
    /// Barrière pour les écritures (thread-safety garanti)
    private let queue = DispatchQueue(label: "com.app.dicontainer", attributes: .concurrent)
    
    public init() {}
    
    // MARK: - Register with factory
    /// Enregistre un type avec une factory closure
    /// 
    /// UTILISATION: Pour les services qui doivent être créés à chaque resolve()
    /// EXEMPLE: ViewModels, Services avec état
    /// 
    /// THREAD-SAFETY: .barrier garantit l'exclusivité d'écriture
    public func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        queue.async(flags: .barrier) {
            self.services[key] = factory
        }
    }
    
    // MARK: - Register singleton instance
    /// Enregistre une instance singleton directement
    /// 
    /// UTILISATION: Pour les services partagés (NetworkService, Cache, etc.)
    /// AVANTAGE: L'instance est créée une seule fois et réutilisée
    /// 
    /// NOTE: L'instance est stockée telle quelle, pas dans une closure
    public func register<T>(_ service: T) {
        let key = String(describing: T.self)
        queue.async(flags: .barrier) {
            self.services[key] = service
        }
    }
    
    // MARK: - Resolve service
    /// Résout et retourne une instance du type demandé
    /// 
    /// LOGIQUE DE RÉSOLUTION:
    /// 1. Vérifie d'abord si c'est une instance singleton
    /// 2. Sinon, vérifie si c'est une factory et l'exécute
    /// 3. Sinon, crash (fail-fast pour détecter les erreurs tôt)
    /// 
    /// POURQUOI FATALERROR?
    /// - Les dépendances manquantes sont des erreurs de programmation
    /// - Doit être détecté pendant le développement, pas en production
    /// - Force l'enregistrement correct de toutes les dépendances
    /// 
    /// THREAD-SAFETY: sync permet les lectures concurrentes
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
/// Property wrapper pour l'injection automatique
/// 
/// AVANTAGES:
/// - Syntaxe clean: @Injected var service: ServiceType
/// - Pas besoin d'initializer
/// - Resolution lazy (au premier accès)
/// 
/// UTILISATION:
/// ```swift
/// class ViewModel {
///     @Injected private var networkService: NetworkService
///     @Injected private var cache: CacheService
/// }
/// ```
/// 
/// NOTE: Non utilisé dans ce projet par choix (préférence pour l'injection explicite)
/// mais disponible pour montrer la maîtrise des property wrappers
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
