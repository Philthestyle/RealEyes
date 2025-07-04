//
//  StoryMapper.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation

struct MockStories {
    static func generateStoryGroups(for response: UsersResponse) -> [StoryGroup] {
        let mockDataProvider = MockDataProvider.shared
        let storyImages = [
            "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800", // Mountain landscape
            "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800", // Food
            "https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800", // City
            "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800", // Beach
            "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800", // Coffee
            "https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800", // Travel
            "https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=800", // Art
            "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800"  // Fitness
        ]
        
        return response.users.enumerated().map { index, apiUser in
            // Use real profile images from MockDataProvider
            let profileImageUrl = mockDataProvider.profileImageUrls[index % mockDataProvider.profileImageUrls.count]
            
            let user = User(
                id: apiUser.id,
                username: apiUser.username,
                firstName: apiUser.firstName,
                lastName: apiUser.lastName,
                image: profileImageUrl // Use real profile photo
            )
            
            var story = StoryGroup(
                user: user,
                imageURL: profileImageUrl,
                timestamp: Date().addingTimeInterval(-Double.random(in: 3600...86400))
            )
            
            // Create stories with real images
            let storyCount = Int.random(in: 2...4)
            story.stories = (0..<storyCount).map { storyIndex in
                let imageIndex = (index * storyCount + storyIndex) % storyImages.count
                return Story(imageURL: storyImages[imageIndex])
            }
            
            story.hasBeenSeen = false // Start with all unseen
            return story
        }
    }
}
