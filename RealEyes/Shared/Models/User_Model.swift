//
//  User_Model.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation

struct User: Identifiable, Codable, Equatable {
    // MARK: - Properties
    
    let id: Int
    let username: String
    let firstName: String
    let lastName: String
    let image: String
    
    // MARK: - Computed Properties
    
    /// Full display name combining first and last name
    var displayName: String {
        "\(firstName) \(lastName)"
    }
    
    /// Converts image string to URL for AsyncImage usage
    var profileImageURL: URL? {
        URL(string: image)
    }
}

// MARK: - UsersResponse

/// API response wrapper for users endpoint
/// Contains pagination info along with user array
struct UsersResponse: Codable {
    let users: [User]
    let total: Int
    let skip: Int
    let limit: Int
}
