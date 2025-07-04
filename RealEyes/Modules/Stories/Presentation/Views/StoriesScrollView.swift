//
//  StoriesScrollView.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI

struct StoriesScrollView: View {
    let stories: [StoryGroup]
    let onStoryTap: (StoryGroup) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 16) {
                // Your story button
                YourStoryButton()
                
                // Infinite stories with LazyHStack for performance
                ForEach(0..<1000, id: \.self) { pageIndex in
                    ForEach(stories.indices, id: \.self) { storyIndex in
                        let storyGroup = stories[storyIndex]
                        StoryItemView(storyGroup: storyGroup)
                            .id("\(pageIndex)-\(storyIndex)-\(storyGroup.id)-\(storyGroup.hasBeenSeen)")
                            .onTapGesture {
                                onStoryTap(storyGroup)
                            }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 4)
        }
    }
}
