//
//  YourStoryButton.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI

struct YourStoryButton: View {
    @StateObject private var profileManager = ProfileImageManager.shared
    @State private var showProfileSetup = false
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .bottomTrailing) {
                // Profile image or placeholder
                if let profileImage = profileManager.profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 90, height: 90)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                        )
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 90, height: 90)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 35))
                                .foregroundColor(.gray)
                        )
                }
                
                // Plus/Edit button - changes based on profile image status
                ZStack {
                    Circle()
                        .fill(Color(UIColor.systemBackground))
                        .frame(width: 26, height: 26)
                    
                    Circle()
                        .fill(profileManager.hasProfileImage ? Color.white : Color.black)
                        .frame(width: 22, height: 22)
                        .overlay(
                            Circle()
                                .stroke(profileManager.hasProfileImage ? Color.gray.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                        .overlay(
                            Image(systemName: profileManager.hasProfileImage ? "pencil" : "plus")
                                .font(.system(size: profileManager.hasProfileImage ? 12 : 14, weight: .bold))
                                .foregroundColor(profileManager.hasProfileImage ? .gray : .white)
                        )
                }
                .offset(x: 2, y: 2)
            }
            .onTapGesture {
                // Always allow changing profile picture
                showProfileSetup = true
            }
            
            Text("Your story")
                .font(.system(size: 12))
                .lineLimit(1)
                .frame(width: 90)
        }
        .sheet(isPresented: $showProfileSetup) {
            ProfileImageSetupView()
        }
    }
}
