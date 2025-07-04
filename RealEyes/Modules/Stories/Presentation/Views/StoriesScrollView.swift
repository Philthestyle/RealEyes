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
            HStack(spacing: 16) {
                // Your story button
                YourStoryButton()
                
                // Story items
                ForEach(stories) { storyGroup in
                    StoryItemView(storyGroup: storyGroup)
                        .id("\(storyGroup.id)-\(storyGroup.hasBeenSeen)") // Force refresh when hasBeenSeen changes
                        .onTapGesture {
                            onStoryTap(storyGroup)
                        }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8) // Add top padding to prevent clipping
            .padding(.bottom, 4) // Add small bottom padding for balance
        }
    }
}
