//
//  Story.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation

// MARK: - Story Type
enum StoryType {
    case image
    case video
}

// MARK: - Story Model
struct Story: Identifiable {
    let id = UUID()
    let mediaURL: String
    let type: StoryType
    let duration: TimeInterval
    
    init(imageURL: String, duration: TimeInterval = 5.0) {
        self.mediaURL = imageURL
        self.type = .image
        self.duration = duration
    }
    
    init(videoURL: String, duration: TimeInterval = 15.0) {
        self.mediaURL = videoURL
        self.type = .video
        self.duration = duration
    }
    
    var url: URL? {
        URL(string: mediaURL)
    }
    
    // Backward compatibility
    var imageURL: String {
        mediaURL
    }
}
