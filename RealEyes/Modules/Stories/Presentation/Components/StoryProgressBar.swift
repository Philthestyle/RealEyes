//
//  StoryProgressBar.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation
import SwiftUI

/// Progress bar displaying story advancement
/// Shows multiple segments representing each story in the group
struct StoryProgressBar: View {
    /// Total number of stories in group
    let numberOfStories: Int
    
    /// Current story index
    let currentIndex: Int
    
    /// Current story progress (0.0 to 1.0)
    let progress: Double
    
    /// Spacing between segments
    private let spacing: CGFloat = 4
    
    /// Animated progress value
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: spacing) {
                ForEach(0..<numberOfStories, id: \.self) { index in
                    ProgressSegment(
                        progress: segmentProgress(for: index),
                        isAnimating: index == currentIndex
                    )
                }
            }
            .frame(height: 3)
        }
        .frame(height: 3)
        .onChange(of: progress) { newValue in
            withAnimation(.linear(duration: 0.1)) {
                animatedProgress = newValue
            }
        }
    }
    
    /// Calculates progress for given segment
    /// - Parameter index: Segment index
    /// - Returns: Progress value (0.0 to 1.0)
    private func segmentProgress(for index: Int) -> Double {
        if index < currentIndex {
            // Completed segments
            return 1.0
        } else if index == currentIndex {
            // Current segment
            return animatedProgress
        } else {
            // Future segments
            return 0.0
        }
    }
}

/// Individual progress bar segment
private struct ProgressSegment: View {
    /// Segment progress (0.0 to 1.0)
    let progress: Double
    
    /// Indicates if this segment is animating
    let isAnimating: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Segment background
                Capsule()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 3)
                
                // Segment progress
                Capsule()
                    .fill(Color.white)
                    .frame(width: geometry.size.width * CGFloat(min(max(progress, 0.0), 1.0)), height: 3)
                    .animation(
                        isAnimating ? .linear(duration: 0.1) : .none,
                        value: progress
                    )
            }
            .clipped()
        }
    }
}

/// Preview for SwiftUI
struct StoryProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // First story in progress
            StoryProgressBar(
                numberOfStories: 5,
                currentIndex: 0,
                progress: 0.6
            )
            
            // Third story in progress
            StoryProgressBar(
                numberOfStories: 5,
                currentIndex: 2,
                progress: 0.3
            )
            
            // Last story nearly complete
            StoryProgressBar(
                numberOfStories: 3,
                currentIndex: 2,
                progress: 0.9
            )
        }
        .padding()
        .background(Color.black)
        .previewLayout(.sizeThatFits)
    }
}
