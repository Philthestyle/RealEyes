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
            
            // Image
            postImage
            
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
    }
    
    private var postHeader: some View {
        HStack {
            // Avatar with story ring
            PostAvatarView(userId: post.userId, hasStory: true, size: 32)
            
            // Username
            Text("user_\(post.userId)")
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
            // Like
            Button(action: handleLike) {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .font(.system(size: 22))
                    .foregroundColor(isLiked ? .red : .primary)
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
        withAnimation(.spring()) {
            isLiked.toggle()
            likes += isLiked ? 1 : -1
        }
        onLike?()
    }
    
    private func handleDoubleTapLike() {
        if !isLiked {
            withAnimation(.spring()) {
                isLiked = true
                likes += 1
            }
            onLike?()
        }
    }
    
    private func handleSave() {
        withAnimation(.spring()) {
            isBookmarked.toggle()
        }
        onSave?()
    }
}
