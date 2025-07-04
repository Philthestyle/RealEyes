//
//  PostServiceProtocol.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation

// MARK: - Post Service Protocol
protocol PostServiceProtocol {
    var posts: [Post] { get }
    func loadPosts() async throws
    func likePost(_ postId: Int) async
    func savePost(_ postId: Int) async
    func loadMockPosts()
}
