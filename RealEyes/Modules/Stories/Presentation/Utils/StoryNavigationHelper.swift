//
//  StoryNavigationHelper.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI
import Combine

// Helper to manage story navigation with smooth animations
class StoryNavigationHandler: ObservableObject {
    static func navigateToStory(_ storyId: String, currentStoryId: Binding<String>) {
        // Use explicit animation for smooth 3D transition
        withAnimation(.easeInOut(duration: 0.4)) {
            currentStoryId.wrappedValue = storyId
        }
    }
}
