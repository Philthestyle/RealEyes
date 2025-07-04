//
//  MockDataProvider.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation

struct MockData {
    /// singleton
    static let shared = MockData()
    
    /// simple mock array to test UI if needed
    static let users = [
        User(id: 1, username: "Ptitin", firstName: "Alice", lastName: "Smith",
             image: "https://randomuser.me/api/portraits/women/1.jpg"),
        User(id: 2, username: "Phil", firstName: "Phil", lastName: "Johnson",
             image: "https://randomuser.me/api/portraits/men/2.jpg"),
        User(id: 3, username: "Chali", firstName: "Charlse", lastName: "Brown",
             image: "https://randomuser.me/api/portraits/men/3.jpg")
    ]
    
    /// generate array of StoryGroup and bind each one of them to a User
    static func generateStories() -> [StoryGroup] {
        users.map { user in
            var story = StoryGroup(
                user: user,
                imageURL: user.image,
                timestamp: Date().addingTimeInterval(-Double.random(in: 3600...86400))
            )
            
            // Generate 2-5 story items per user
            let storyCount = Int.random(in: 2...5)
            story.stories = (0..<storyCount).map { index in
                Story(imageURL: "https://picsum.photos/400/600?random=\(user.id)_\(index)")
            }
                
            // Random seen status
            story.hasBeenSeen = Bool.random()
            
            return story
        }
    }
}
