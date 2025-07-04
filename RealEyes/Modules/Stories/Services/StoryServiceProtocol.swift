//
//  StoryServiceProtocol.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation

// MARK: - Story Service Protocol
/// I have decided to separate ServiceProtocols from their Service to have a better visibility of the code
protocol StoryServiceProtocol {
    // MARK: - Properties
    var stories: [StoryGroup] { get }
    
    // MARK: - Methods
    func loadStories() async throws
}
