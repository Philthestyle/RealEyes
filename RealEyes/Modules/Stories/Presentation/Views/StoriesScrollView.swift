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
                
                // ✅ FIX: Infinite stories avec IDs stables
                ForEach(0..<1000, id: \.self) { pageIndex in
                    ForEach(stories.indices, id: \.self) { storyIndex in
                        let storyGroup = stories[storyIndex]
                        StoryItemView(storyGroup: storyGroup)
                            // 🎯 ID avec l'état "seen" pour forcer refresh UI
                            .id("\(pageIndex)-\(storyGroup.id)-\(storyGroup.hasBeenSeen)")
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