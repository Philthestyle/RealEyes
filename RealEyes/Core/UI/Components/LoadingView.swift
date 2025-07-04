//
//  LoadingView.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//


import SwiftUI

// MARK: - Loading View Style
enum LoadingViewStyle {
    case stories
    case feed
    case fullScreen
    case inline
    case skeleton
}

// MARK: - Loading View Component
struct LoadingView: View {
    let style: LoadingViewStyle
    let message: String?
    
    init(style: LoadingViewStyle = .fullScreen, message: String? = nil) {
        self.style = style
        self.message = message
    }
    
    var body: some View {
        switch style {
        case .stories:
            storiesLoadingView
        case .feed:
            feedLoadingView
        case .fullScreen:
            fullScreenLoadingView
        case .inline:
            inlineLoadingView
        case .skeleton:
            skeletonLoadingView
        }
    }
    
    // MARK: - Stories Loading
    private var storiesLoadingView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(0..<6, id: \.self) { _ in
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
            .padding(.horizontal)
        }
//        .modifier(ShimmerModifier())
    }
    
    // MARK: - Feed Loading
    private var feedLoadingView: some View {
        VStack(spacing: 20) {
            ForEach(0..<3, id: \.self) { _ in
                PostSkeletonView()
            }
        }
    }
    
    // MARK: - Full Screen Loading
    private var fullScreenLoadingView: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.primary)
                
                if let message = message {
                    Text(message)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
        }
    }
    
    // MARK: - Inline Loading
    private var inlineLoadingView: some View {
        HStack(spacing: 12) {
            ProgressView()
                .scaleEffect(0.8)
            
            if let message = message {
                Text(message)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Skeleton Loading
    private var skeletonLoadingView: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(0..<3, id: \.self) { _ in
                VStack(alignment: .leading, spacing: 12) {
                    // Header skeleton
                    HStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 120, height: 12)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 80, height: 10)
                        }
                        
                        Spacer()
                    }
                    
                    // Content skeleton
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                    
                    // Footer skeleton
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 200, height: 12)
                    }
                }
                .padding()
//                .modifier(ShimmerModifier())
            }
        }
    }
}

// MARK: - Post Skeleton View
struct PostSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 12)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 10)
                }
                
                Spacer()
                
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 20, height: 20)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Image placeholder
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(1, contentMode: .fit)
            
            // Actions
            HStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { _ in
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 24, height: 24)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Caption
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 12)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 200, height: 12)
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
//        .modifier(ShimmerModifier())
    }
}

// MARK: - Preview
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            LoadingView(style: .stories)
                .frame(height: 100)
            
            LoadingView(style: .inline, message: "Loading...")
            
            LoadingView(style: .feed)
        }
        .padding()
    }
}
