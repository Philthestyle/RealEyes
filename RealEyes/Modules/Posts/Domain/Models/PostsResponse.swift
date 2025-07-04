//
//  PostsResponse.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation

// Response model for DummyJSON posts API
struct PostsResponse: Codable {
    let posts: [Post]
    let total: Int
    let skip: Int
    let limit: Int
}
