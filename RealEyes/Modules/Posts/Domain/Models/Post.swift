//
//  Post.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation

struct Post: Identifiable, Codable, Equatable {
    let id: Int
    let title: String
    let body: String
    let userId: Int
    let tags: [String]
    let reactions: Reactions?
    
    var imageURL: String {
        "https://picsum.photos/400/400?random=\(id)"
    }
    
    var imageURLObject: URL? {
        URL(string: imageURL)
    }
}

// MARK: - Post Reactions
struct Reactions: Codable, Equatable {
    let likes: Int
    let dislikes: Int
}

// Extension to support custom image URLs
extension Post {
    private static var customImageURLs: [Int: String] = [:]
    
    mutating func setCustomImageURL(_ url: String) {
        Post.customImageURLs[id] = url
    }
    
    var customImageURL: String? {
        Post.customImageURLs[id]
    }
    
    var displayImageURL: String {
        customImageURL ?? imageURL
    }
    
    var displayImageURLObject: URL? {
        URL(string: displayImageURL)
    }
}

// Factory extension for creating posts with custom images
extension Post {
    static func createWithCustomImage(
        id: Int,
        title: String,
        body: String,
        userId: Int,
        tags: [String],
        reactions: Reactions?,
        imageURL: String
    ) -> Post {
        var post = Post(
            id: id,
            title: title,
            body: body,
            userId: userId,
            tags: tags,
            reactions: reactions
        )
        post.setCustomImageURL(imageURL)
        return post
    }
}
