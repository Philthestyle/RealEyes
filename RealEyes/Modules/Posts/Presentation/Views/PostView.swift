//
//  PostView.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI

struct PostView: View {
    let post: Post
    let onLike: (() -> Void)?
    let onSave: (() -> Void)?
    
    @State private var isLiked = false
    @State private var isBookmarked = false
    @State private var likes: Int
    @State private var showHeartAnimation = false
    @State private var heartScale: CGFloat = 1.0
    
    // Haptic feedback generator
    private let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
    
    init(post: Post, onLike: (() -> Void)? = nil, onSave: (() -> Void)? = nil) {
        self.post = post
        self.onLike = onLike
        self.onSave = onSave
        self._likes = State(initialValue: post.reactions?.likes ?? 0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            postHeader
            
            // Image with heart animation overlay
            ZStack {
                postImage
                
                // Heart animation overlay
                if showHeartAnimation {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 100))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 10)
                        .scaleEffect(showHeartAnimation ? 1.2 : 0.5)
                        .opacity(showHeartAnimation ? 0 : 1)
                        .animation(.easeOut(duration: 0.6), value: showHeartAnimation)
                }
            }
            
            // Actions
            postActions
            
            // Likes count
            if likes > 0 {
                Text("\(likes) likes")
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.horizontal)
                    .padding(.bottom, 4)
            }
            
            // Caption
            postCaption
        }
        .background(Color(UIColor.systemBackground))
        .onAppear {
            // Prepare haptic engine
            impactFeedback.prepare()
        }
    }
    
    private var postHeader: some View {
        HStack {
            // Avatar with story ring
            PostAvatarView(userId: post.userId, hasStory: true, size: 32)
            
            // Username
            Text(post.title)
                .font(.system(size: 14, weight: .semibold))
            
            Spacer()
            
            // More button
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var postImage: some View {
        AsyncImage(url: post.displayImageURLObject) { phase in
            switch phase {
            case .empty:
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        ProgressView()
                    )
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .failure(_):
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("Failed to load")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    )
            @unknown default:
                EmptyView()
            }
        }
        .onTapGesture(count: 2) {
            handleDoubleTapLike()
        }
    }
    
    private var postActions: some View {
        HStack(spacing: 16) {
            // Like with scale animation
            Button(action: handleLike) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 22))
                    .foregroundColor(isLiked ? .red : .primary)
                    .scaleEffect(heartScale)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: heartScale)
            }
            
            // Comment
            Button(action: {}) {
                Image(systemName: "bubble.right")
                    .font(.system(size: 22))
                    .foregroundColor(.primary)
            }
            
            // Share
            Button(action: {}) {
                Image(systemName: "paperplane")
                    .font(.system(size: 22))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Bookmark
            Button(action: handleSave) {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 22))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var postCaption: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Title
            Text(post.title)
                .font(.system(size: 14, weight: .semibold))
            
            // Body
            Text(post.body)
                .font(.system(size: 14))
                .foregroundColor(.primary.opacity(0.8))
            
            // Tags
            if !post.tags.isEmpty {
                Text(post.tags.map { "#\($0)" }.joined(separator: " "))
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
                    .padding(.top, 4)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
    
    // MARK: - Actions
    private func handleLike() {
        // Haptic feedback
        impactFeedback.impactOccurred()
        
        withAnimation(.spring()) {
            isLiked.toggle()
            likes += isLiked ? 1 : -1
        }
        
        // Animate heart button
        animateHeartButton()
        
        onLike?()
    }
    
    private func handleDoubleTapLike() {
        // Strong haptic feedback for double tap
        impactFeedback.impactOccurred()
        
        // Toggle like state on double tap
        withAnimation(.spring()) {
            isLiked.toggle()
            likes += isLiked ? 1 : -1
        }
        
        // Animate the heart button
        animateHeartButton()
        
        // Always show heart animation
        showHeartAnimation = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            showHeartAnimation = false
        }
        
        onLike?()
    }
    
    private func animateHeartButton() {
        // Bounce animation for heart button
        heartScale = 1.3
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            heartScale = 1.0
        }
    }
    
    private func handleSave() {
        // Light haptic for bookmark
        let lightImpact = UIImpactFeedbackGenerator(style: .light)
        lightImpact.impactOccurred()
        
        withAnimation(.spring()) {
            isBookmarked.toggle()
        }
        onSave?()
    }
}
