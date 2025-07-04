//
//  ReelsView.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation
import SwiftUI

struct ReelsView: View {
    @State private var currentReel = 0
    
    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()
            
            // Reels content
            TabView(selection: $currentReel) {
                ForEach(0..<10) { index in
                    ReelItemView(index: index)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            // Overlay UI
            VStack {
                // Top bar
                ReelsTopBar()
                
                Spacer()
            }
        }
        .statusBar(hidden: true)
    }
}

struct ReelsTopBar: View {
    var body: some View {
        HStack {
            Text("Reels")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "camera")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal)
        .padding(.top, 60)
    }
}

struct ReelItemView: View {
    let index: Int
    @State private var isLiked = false
    @State private var isFollowing = false
    
    var body: some View {
        ZStack {
            // Video placeholder with gradient
            LinearGradient(
                colors: [
                    Color(hue: Double(index) * 0.1, saturation: 0.8, brightness: 0.8),
                    Color(hue: Double(index) * 0.1 + 0.1, saturation: 0.8, brightness: 0.6)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Content overlay
            VStack {
                Spacer()
                
                HStack(alignment: .bottom) {
                    // Left side - User info and description
                    VStack(alignment: .leading, spacing: 12) {
                        // User info
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text("\(index + 1)")
                                        .font(.system(size: 14, weight: .bold))
                                )
                            
                            Text("user_\(index + 1)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                            
                            if !isFollowing {
                                Button(action: { isFollowing.toggle() }) {
                                    Text("Follow")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        
                        // Description
                        Text("Amazing reel content #\(index + 1) 🎬")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        // Audio info
                        HStack(spacing: 6) {
                            Image(systemName: "music.note")
                                .font(.system(size: 12))
                            Text("Original audio")
                                .font(.system(size: 13))
                        }
                        .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Right side - Action buttons
                    VStack(spacing: 20) {
                        // Like button
                        VStack(spacing: 4) {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    isLiked.toggle()
                                }
                            }) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .font(.system(size: 28))
                                    .foregroundColor(isLiked ? .red : .white)
                                    .scaleEffect(isLiked ? 1.2 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isLiked)
                            }
                            
                            Text("\(Int.random(in: 100...9999))")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                        }
                        
                        // Comment button
                        VStack(spacing: 4) {
                            Button(action: {}) {
                                Image(systemName: "message")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                            }
                            
                            Text("\(Int.random(in: 10...999))")
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                        }
                        
                        // Share button
                        Button(action: {}) {
                            Image(systemName: "paperplane")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                        }
                        
                        // More button
                        Button(action: {}) {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                        }
                        
                        // Audio cover
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 30, height: 30)
                            
                            Image(systemName: "music.note")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.white, lineWidth: 1)
                        )
                    }
                    .padding(.trailing)
                }
                .padding(.bottom, 100) // Space for tab bar
            }
        }
        .ignoresSafeArea()
    }
}
