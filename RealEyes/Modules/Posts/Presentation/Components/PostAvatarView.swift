//
//  PostAvatarView.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI

struct PostAvatarView: View {
    let userId: Int
    let hasStory: Bool
    let size: CGFloat
    
    private let mockDataProvider = MockDataProvider.shared
    
    var body: some View {
        ZStack {
            if hasStory {
                // Story ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.7, green: 0.0, blue: 0.8),
                                Color(red: 1.0, green: 0.0, blue: 0.4),
                                Color(red: 1.0, green: 0.6, blue: 0.0),
                                Color(red: 1.0, green: 0.8, blue: 0.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: size + 4, height: size + 4)
            }
            
            // Profile image
            if let user = mockDataProvider.generateMockUsers().first(where: { $0.id == userId }) {
                AsyncImage(url: user.profileImageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                    case .failure(_), .empty:
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: size, height: size)
                            .overlay(
                                Text(String(user.firstName.prefix(1)))
                                    .font(.system(size: size * 0.4, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                // Fallback avatar
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: size, height: size)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: size * 0.5))
                            .foregroundColor(.gray)
                    )
            }
        }
    }
}
