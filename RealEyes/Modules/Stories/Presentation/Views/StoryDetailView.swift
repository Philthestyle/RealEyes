//
//  StoryDetailView.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI

struct StoryDetailView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Binding var currentStory: String
    @Binding var showStory: Bool
    @Binding var isAnimating: Bool
    
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    
    var body: some View {
        if showStory {
            ZStack {
                // Background with opacity based on drag
                Color.black
                    .ignoresSafeArea()
                    .opacity(1 - min(abs(dragOffset.height) / 300.0, 0.8))
                
                TabView(selection: $currentStory) {
                    ForEach(viewModel.storyGroups) { bundle in
                        StoryCardView(
                            storyGroup: bundle,
                            stories: viewModel.storyGroups,
                            currentStoryId: $currentStory,
                            showStory: $showStory,
                            isAnimating: $isAnimating,
                            onMarkAsSeen: { storyId in
                                if let storyGroup = viewModel.storyGroups.first(where: { $0.id == storyId }) {
                                    viewModel.markStoryGroupAsSeen(storyGroup)
                                }
                            }
                        )
                        .tag(bundle.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
                .disabled(isAnimating)
                // Apply drag offset and scale with card detaching effect
                .scaleEffect(1 - min(abs(dragOffset.height) / 1200, 0.12))
                .shadow(color: .black.opacity(isDragging ? 0.15 : 0), radius: isDragging ? 22 : 0, x: 0, y: 6)
                .clipShape(RoundedRectangle(cornerRadius: isDragging ? min(abs(dragOffset.height) / 6, 32) : 0, style: .continuous))
                .offset(y: dragOffset.height)
                .animation(.interactiveSpring(), value: isDragging)
                .animation(.easeInOut, value: dragOffset)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Only allow dragging down
                        if value.translation.height > 0 {
                            dragOffset = value.translation
                            isDragging = true
                        }
                    }
                    .onEnded { value in
                        // Dismiss if dragged more than 200 points
                        if value.translation.height > 200 {
                            withAnimation(.easeOut(duration: 0.3)) {
                                showStory = false
                            }
                        } else {
                            // Snap back to original position
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                dragOffset = .zero
                                isDragging = false
                            }
                        }
                    }
            )
        }
    }
}

