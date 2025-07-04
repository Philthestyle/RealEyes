//
//  ViewState.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation

/// Generic view state for handling async operations
/// Provides a clean way to manage loading, success, and error states
enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error)
    
    // MARK: - Computed Properties
    
    /// Indicates if the state is currently loading
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    /// Returns the loaded data if available
    var data: T? {
        if case .loaded(let data) = self { return data }
        return nil
    }
    
    /// Returns the error if in error state
    var error: Error? {
        if case .error(let error) = self { return error }
        return nil
    }
}
