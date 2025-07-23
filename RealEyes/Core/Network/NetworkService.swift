//
//  NetworkService.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//


import Foundation

/// Service réseau générique utilisant async/await
/// 
/// ARCHITECTURE DU NETWORK LAYER:
/// 1. Générique avec Swift Generics
/// 2. Async/await pour la simplicité (pas de callback hell)
/// 3. Type-safe avec Decodable
/// 4. Error handling centralisé
/// 
/// POURQUOI UN SERVICE GÉNÉRIQUE ?
/// - Réutilisabilité : Une seule méthode pour tous les endpoints
/// - Type safety : Le compilateur vérifie les types
/// - Maintenance : Changements centralisés
/// - Testabilité : Facile à mocker
final class NetworkService {
    /// Singleton pour partage global
    /// JUSTIFICATION: 
    /// - URLSession est thread-safe
    /// - Évite de créer plusieurs sessions
    /// - Configuration centralisée
    static let shared = NetworkService()
    
    private let session = URLSession.shared
    private let decoder = JSONDecoder()
    
    private init() {
        // CONFIGURATION DU DECODER
        // convertFromSnakeCase : API typiques utilisent snake_case
        // Swift utilise camelCase
        // Conversion automatique : user_name -> userName
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    /// Méthode générique pour fetch et decode
    /// 
    /// GENERICS EXPLANATION:
    /// - T: Decodable : Le type doit implémenter Decodable
    /// - type: T.Type : Passé explicitement pour l'inférence de type
    /// - return T : Type-safe, pas de casting nécessaire
    /// 
    /// AVANTAGES vs COMPLETION HANDLERS:
    /// 1. Code linéaire (pas de pyramid of doom)
    /// 2. Error handling avec try/catch standard
    /// 3. Compatible avec Swift Concurrency
    /// 4. Annulation automatique avec Task
    /// 
    /// LIMITES ACTUELLES:
    /// - Seulement GET (suffisant pour ce projet)
    /// - Pas de headers custom
    /// - Pas de retry automatique
    /// Pour un vrai projet, utiliser Alamofire ou Moya
    func fetch<T: Decodable>(_ type: T.Type, from urlString: String) async throws -> T {
        // VALIDATION URL
        // Fail fast si URL invalide
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        // ASYNC/AWAIT NETWORK CALL
        // Automatiquement annulable si la Task est cancel
        // Pas de retain cycle possible (pas de closures)
        let (data, response) = try await session.data(from: url)
        
        // VALIDATION HTTP STATUS
        // Cast en HTTPURLResponse pour accéder au statusCode
        // Range 200-299 = succès HTTP standard
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        // DECODING AVEC ERROR HANDLING
        // do/catch séparé pour wrapper l'erreur de décodage
        // Permet de debugger facilement les problèmes de parsing
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}

/// Enum pour les erreurs réseau
/// 
/// POURQUOI UN ENUM CUSTOM ?
/// 1. Type-safe error handling
/// 2. Cas exhaustifs avec switch
/// 3. Associated values pour plus de contexte
/// 4. LocalizedError pour messages user-friendly
/// 
/// PATTERN: Result type implicit avec throws
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    
    /// Description localisée pour l'UI
    /// Implémentation de LocalizedError protocol
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingError(let error):
            // Propagation de l'erreur originale pour debugging
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}
