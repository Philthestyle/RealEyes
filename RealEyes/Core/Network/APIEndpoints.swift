//
//  APIEndpoints.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation

/// API endpoints constants
enum APIEndpoints {
    // decided to use this API that should be great to display a list of Users and bind each one of them a 'StoryGroup'
    static let baseURL = "https://dummyjson.com"
    
    static let users = "\(baseURL)/users"
    static let posts = "\(baseURL)/posts"
    static let userById = "\(baseURL)/users/%@"
    static let postsByUser = "\(baseURL)/posts/user/%@"
    static let comments = "\(baseURL)/comments"
    static let commentsByPost = "\(baseURL)/comments/post/%@"
    
    /// Get user endpoint with ID
    static func user(id: String) -> String {
        String(format: userById, id)
    }
    
    /// Get posts by user endpoint
    static func posts(userId: String) -> String {
        String(format: postsByUser, userId)
    }
    
    /// Get comments by post endpoint
    static func comments(postId: String) -> String {
        String(format: commentsByPost, postId)
    }
}
