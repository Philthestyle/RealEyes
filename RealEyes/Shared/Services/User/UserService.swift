//
//  UserService.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation



final class UserService: UserServiceProtocol {
    @Injected private var networkService: NetworkService
    
    func fetchUsers(limit: Int) async throws -> [User] {
        let response = try await networkService.fetch(
            UsersResponse.self,
            from: "\(APIEndpoints.users)?limit=\(limit)"
        )
        return response.users
    }
    
    func fetchUser(id: Int) async throws -> User? {
        let user = try await networkService.fetch(
            User.self,
            from: APIEndpoints.user(id: String(id))
        )
        return user
    }
}
