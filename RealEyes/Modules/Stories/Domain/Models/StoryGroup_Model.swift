//
//  StoryGroup.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI

// MARK: - Story Group Model
struct StoryGroup: Identifiable {
    // ✅ FIX: ID stable basé sur les données
    let id: String
    let user: User
    let imageURL: String
    let timestamp: Date
    var hasBeenSeen: Bool = false
    var stories: [Story] = []
    
    // ✅ Constructeur avec ID déterministe
    init(user: User, imageURL: String, timestamp: Date, hasBeenSeen: Bool = false, stories: [Story] = []) {
        self.user = user
        self.imageURL = imageURL
        self.timestamp = timestamp
        self.hasBeenSeen = hasBeenSeen
        self.stories = stories
        
        // 🎯 ID stable : combinaison user.id + timestamp
        let timestampInt = Int(timestamp.timeIntervalSince1970)
        self.id = "story_\(user.id)_\(timestampInt)"
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

extension StoryGroup: Equatable {
    static func == (lhs: StoryGroup, rhs: StoryGroup) -> Bool {
        lhs.id == rhs.id
    }
}

// ✅ BONUS: Conformance Codable pour la persistance
extension StoryGroup: Codable {
    enum CodingKeys: String, CodingKey {
        case id, user, imageURL, timestamp, hasBeenSeen, stories
    }
}