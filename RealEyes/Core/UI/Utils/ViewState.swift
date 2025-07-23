//
//  ViewState.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation

/// État générique pour gérer les opérations asynchrones
/// 
/// PATTERN VIEWSTATE - POURQUOI ?
/// 1. Un seul état à la fois (impossible d'être loading ET error)
/// 2. Type-safe avec associated values
/// 3. Exhaustif avec switch (le compilateur vérifie tous les cas)
/// 4. Réutilisable pour n'importe quel type T
/// 
/// AVANTAGES vs BOOLEANS MULTIPLES:
/// - Pas de isLoading + hasError + data (états incohérents possibles)
/// - Plus expressif et lisible
/// - Force à gérer tous les cas
/// 
/// INSPIRATION: 
/// - Pattern courant dans l'architecture Redux
/// - Similaire à Result<T, Error> mais avec plus d'états
enum ViewState<T> {
    /// État initial, aucune action entreprise
    case idle
    
    /// Chargement en cours
    case loading
    
    /// Chargement réussi avec données
    case loaded(T)
    
    /// Erreur survenue
    case error(Error)
    
    // MARK: - Computed Properties
    
    /// Indique si l'état est en chargement
    /// 
    /// UTILISATION: 
    /// ```swift
    /// if viewModel.state.isLoading {
    ///     ProgressView()
    /// }
    /// ```
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    /// Retourne les données si disponibles
    /// 
    /// PATTERN MATCHING avec if-case-let
    /// Plus élégant que switch pour extraire une valeur
    var data: T? {
        if case .loaded(let data) = self { return data }
        return nil
    }
    
    /// Retourne l'erreur si présente
    /// 
    /// UTILISATION TYPIQUE:
    /// ```swift
    /// if let error = state.error {
    ///     ErrorView(error: error)
    /// }
    /// ```
    var error: Error? {
        if case .error(let error) = self { return error }
        return nil
    }
}
