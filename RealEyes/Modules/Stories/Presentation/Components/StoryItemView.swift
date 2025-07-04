//
//  StoryItemView.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI

struct StoryItemView: View {
    let storyGroup: StoryGroup
    @State private var imageLoaded = false
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Gradient ring - Instagram size
                GradientCircleView(size: 90, lineWidth: 3.5, isSeen: storyGroup.hasBeenSeen)
                
                // White border
                Circle()
                    .fill(Color(UIColor.systemBackground))
                    .frame(width: 82, height: 82)
                
                // Grey border for separation
                Circle()
                    .stroke(Color.gray.opacity(0.1), lineWidth: 0.5)
                    .frame(width: 78, height: 78)
                
                // Profile image with loading state
                AsyncImage(url: storyGroup.user.profileImageURL) { phase in
                    switch phase {
                    case .empty:
                        // Loading placeholder
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 78, height: 78)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(0.8)
                            )
                            .onAppear {
                                imageLoaded = false
                            }
                        
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 78, height: 78)
                            .clipShape(Circle())
                            .transition(.opacity.combined(with: .scale(scale: 0.8)))
                            .onAppear {
                                withAnimation(.easeOut(duration: 0.3)) {
                                    imageLoaded = true
                                }
                            }
                        
                    case .failure(_):
                        // Fallback with user initials
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hue: Double(storyGroup.user.id % 10) * 0.1, saturation: 0.6, brightness: 0.8),
                                        Color(hue: Double(storyGroup.user.id % 10) * 0.1 + 0.1, saturation: 0.6, brightness: 0.6)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 78, height: 78)
                            .overlay(
                                Text(getInitials(from: storyGroup.user.displayName))
                                    .font(.system(size: 28, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                        
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            // Username
            Text(storyGroup.user.username)
                .font(.system(size: 12))
                .lineLimit(1)
                .frame(width: 90)
        }
    }
    
    private func getInitials(from name: String) -> String {
        let components = name.split(separator: " ")
        let initials = components.compactMap { $0.first }.prefix(2)
        return String(initials).uppercased()
    }
}
