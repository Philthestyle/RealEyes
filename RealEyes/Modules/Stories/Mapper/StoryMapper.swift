//
//  StoryMapper.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation

struct MockStories {
    static func generateStoryGroups(for response: UsersResponse) -> [StoryGroup] {
        return response.users.map { user in
            var story = StoryGroup(
                user: user,
                imageURL: user.image,
                timestamp: Date().addingTimeInterval(-Double.random(in: 3600...86400))
            )
            
            let storyCount = Int.random(in: 2...5)
            story.stories = (0..<storyCount).map { index in
                Story(imageURL: "https://picsum.photos/400/600?random=\(user.id)_\(index)")
            }
            
            story.hasBeenSeen = Bool.random()
            return story
        }
    }
}
