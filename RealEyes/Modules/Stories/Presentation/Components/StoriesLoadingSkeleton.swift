//
//  StoriesLoadingSkeleton.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI

struct StoriesLoadingSkeleton: View {
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0..<6, id: \.self) { _ in
                    StoryItemSkeleton()
                }
            }
            .padding(.horizontal)
        }
    }
}

struct StoryItemSkeleton: View {
    var body: some View {
        VStack(spacing: 6) {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 80, height: 80)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 10)
        }
    }
}
