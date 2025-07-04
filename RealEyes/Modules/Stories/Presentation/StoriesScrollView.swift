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
                //TODO: Create Your story button view
                // YourStoryButtonCircleView
                
                // Story items
                ForEach(stories) { storyGroup in
                   // StoryCircleGradientProfilePictureView
                    StoryItemView(storyGroup: storyGroup)
                        .id("\(storyGroup.id)-\(storyGroup.hasBeenSeen)") // Force refresh when hasBeenSeen changes
                        .onTapGesture {
                            //TODO: manage isShowing StoryGroupDetailView bottomSheet
                        }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8) // Add top padding to prevent clipping
            .padding(.bottom, 4) // Add small bottom padding for balance
        }
    }
}
