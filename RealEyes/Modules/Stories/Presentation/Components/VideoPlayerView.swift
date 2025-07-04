//
//  VideoPlayerView.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoURL: URL
    @State private var player: AVPlayer?
    
    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                setupPlayer()
            }
            .onDisappear {
                player?.pause()
                player = nil
            }
    }
    
    private func setupPlayer() {
        player = AVPlayer(url: videoURL)
        player?.play()
        
        // Loop video
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: .main
        ) { _ in
            player?.seek(to: .zero)
            player?.play()
        }
    }
}

// Simple video placeholder for stories
struct StoryVideoView: View {
    let videoName: String
    
    var body: some View {
        ZStack {
            // Video placeholder with gradient
            LinearGradient(
                colors: [
                    Color.purple.opacity(0.8),
                    Color.pink.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Video Story")
                    .font(.headline)
                    .foregroundColor(.white)
            }
        }
    }
}
