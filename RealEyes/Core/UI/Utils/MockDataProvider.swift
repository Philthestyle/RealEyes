//
//  MockDataProvider.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation
import UIKit

class MockDataProvider {
    static let shared = MockDataProvider()
    private let cache = SessionDataCache.shared
    
    // High-quality profile images URLs from Unsplash
    let profileImageUrls = [
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400", // Woman 1 - Professional
        "https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=400", // Man 1 - Smiling
        "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400", // Man 2 - Avatar style
        "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400", // Woman 2 - Casual
        "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400", // Man 3 - Outdoor
        "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400", // Woman 3 - Portrait
        "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400", // Man 4 - Professional
        "https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=400", // Man 5 - Glasses
        "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400", // Woman 4 - Fashion
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400"  // Man 6 - Friendly
    ]
    
    func generateMockUsers() -> [User] {
        // Return cached users if available
        if let cachedUsers = cache.getCachedUsers() {
            return cachedUsers
        }
        
        // Generate new users and cache them
        let users = [
            User(id: 1, username: "naturelover", firstName: "Alice", lastName: "Johnson",
                 image: profileImageUrls[0]),
            User(id: 2, username: "foodie_life", firstName: "Bob", lastName: "Smith",
                 image: profileImageUrls[1]),
            User(id: 3, username: "urban_explorer", firstName: "Charlie", lastName: "Brown",
                 image: profileImageUrls[2]),
            User(id: 4, username: "beachvibes", firstName: "Diana", lastName: "Wilson",
                 image: profileImageUrls[3]),
            User(id: 5, username: "coffeeaddict", firstName: "Evan", lastName: "Davis",
                 image: profileImageUrls[4]),
            User(id: 6, username: "wanderlust", firstName: "Fiona", lastName: "Garcia",
                 image: profileImageUrls[5]),
            User(id: 7, username: "artistry", firstName: "George", lastName: "Miller",
                 image: profileImageUrls[6]),
            User(id: 8, username: "fitlife", firstName: "Helen", lastName: "Taylor",
                 image: profileImageUrls[7])
        ]
        
        cache.setCachedUsers(users)
        return users
    }
    
    func generateMockStories() -> [StoryGroup] {
        // Return cached stories if available
        if let cachedStories = cache.getCachedStories() {
            return cachedStories
        }
        
        // Generate new stories and cache them
        let users = generateMockUsers()
        let storyContent = [
            // Mix of images and videos
            [
                Story(imageURL: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800"),
                Story(videoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
                Story(imageURL: "https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800")
            ],
            
            [
                Story(imageURL: "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800"),
                Story(imageURL: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800")
            ],
            
            [
                Story(videoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"),
                Story(imageURL: "https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800"),
                Story(imageURL: "https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=800")
            ],
            
            [
                Story(imageURL: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800"),
                Story(imageURL: "https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=800")
            ],
            
            [
                Story(imageURL: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800"),
                Story(videoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"),
                Story(imageURL: "https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=800")
            ],
            
            [
                Story(imageURL: "https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800"),
                Story(imageURL: "https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=800")
            ],
            
            [
                Story(imageURL: "https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=800"),
                Story(imageURL: "https://images.unsplash.com/photo-1547891654-e66ed7ebb968?w=800"),
                Story(videoURL: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4")
            ],
            
            [
                Story(imageURL: "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800"),
                Story(imageURL: "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800")
            ]
        ]
        
        let stories = users.enumerated().map { index, user in
            var storyGroup = StoryGroup(
                user: user,
                imageURL: user.image,
                timestamp: Date().addingTimeInterval(-Double.random(in: 3600...86400))
            )
            
            // Add stories for this user
            storyGroup.stories = storyContent[index % storyContent.count]
            
            // Randomly mark some as seen
            storyGroup.hasBeenSeen = index > 4
            
            return storyGroup
        }
        
        cache.setCachedStories(stories)
        return stories
    }
    
    func generateMockPosts() -> [Post] {
        // Return cached posts if available
        if let cachedPosts = cache.getCachedPosts() {
            return cachedPosts
        }
        
        // Generate new posts and cache them
        let users = generateMockUsers()
        let postContent = [
            (image: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1200",
             caption: "Morning hike with breathtaking views 🏔️ #nature #hiking #mountains"),
            (image: "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200",
             caption: "Homemade brunch goals 🥞 #foodie #brunch #weekend"),
            (image: "https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=1200",
             caption: "City lights never get old ✨ #citylife #nightphotography"),
            (image: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=1200",
             caption: "Beach therapy 🌊 #beachday #paradise #summer"),
            (image: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=1200",
             caption: "But first, coffee ☕ #coffeetime #morningvibes"),
            (image: "https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=1200",
             caption: "Adventure awaits 🗺️ #travel #wanderlust #explore"),
            (image: "https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=1200",
             caption: "Creating something beautiful 🎨 #art #creative #passion"),
            (image: "https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=1200",
             caption: "Never skip leg day 💪 #fitness #gym #motivation")
        ]
        
        let posts = postContent.enumerated().map { index, content in
            let user = users[index % users.count]
            return Post.createWithCustomImage(
                id: index + 1,
                title: user.username,
                body: content.caption,
                userId: user.id,
                tags: ["instagram", "bestories"],
                reactions: Reactions(
                    likes: Int.random(in: 50...500),
                    dislikes: Int.random(in: 0...10)
                ),
                imageURL: content.image
            )
        }
        
        cache.setCachedPosts(posts)
        return posts
    }
}
