//
//  StoryService.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation


// MARK: - Story Service Implementation
final class StoryService: StoryServiceProtocol {
    private let networkService: NetworkService
    
    private(set) var stories: [StoryGroup] = []
    
    init() {
        self.networkService = DIContainer.shared.resolveOptional() ?? NetworkService.shared
    }
    
    func loadStories() async throws {
        do {
            // Try to fetch users from API
            let response = try await self.networkService.fetch(
                UsersResponse.self,
                from: "\(APIEndpoints.users)?limit=10"
            )
            
            stories = MockStories.generateStoryGroups(for: response)
            
        } catch {
            // Fallback to high-quality mock data
            print("Failed to load from API, using mock data: \(error)")
        }
    }
}
