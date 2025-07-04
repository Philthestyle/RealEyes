//
//  StoryGroup.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI

// MARK: - Story Group Model
struct StoryGroup: Identifiable {
    let id = UUID()
    let user: User
    let imageURL: String
    let timestamp: Date
    var hasBeenSeen: Bool = false
    var stories: [Story] = []
    
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
