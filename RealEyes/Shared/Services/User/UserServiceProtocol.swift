//
//  UserServiceProtocol.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation

protocol UserServiceProtocol {
    func fetchUsers(limit: Int) async throws -> [User]
    func fetchUser(id: Int) async throws -> User?
}
