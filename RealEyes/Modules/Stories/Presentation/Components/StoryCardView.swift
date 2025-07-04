//
//  StoryCardView.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI
import Combine
import QuartzCore

// MARK: - StoryProgressDriver using CADisplayLink for smooth 60fps animations
final class StoryProgressDriver: ObservableObject {
    @Published var progress: Double = 0.0
    
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval?
    private var duration: Double = 5.0
    private var pausedTime: CFTimeInterval = 0
    private var isPaused: Bool = false
    
    func start(duration: Double) {
        stop()
        self.duration = duration
        progress = 0.0
        startTime = CACurrentMediaTime()
        pausedTime = 0
        isPaused = false
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    func pause() {
        guard !isPaused, let start = startTime else { return }
        isPaused = true
        pausedTime = CACurrentMediaTime() - start
        displayLink?.isPaused = true
    }
    
    func resume() {
        guard isPaused else { return }
        isPaused = false
        startTime = CACurrentMediaTime() - pausedTime
        displayLink?.isPaused = false
    }
    
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        startTime = nil
        pausedTime = 0
        isPaused = false
        progress = 0.0
    }
    
    @objc private func updateProgress() {
        guard let start = startTime else { return }
        let elapsed = CACurrentMediaTime() - start
        let newProgress = min(elapsed / duration, 1.0)
        
        // Update on main thread for smooth UI updates
        if Thread.isMainThread {
            self.progress = newProgress
        } else {
            DispatchQueue.main.async {
                self.progress = newProgress
            }
        }
        
        if newProgress >= 1.0 {
            displayLink?.isPaused = true
        }
    }
}

struct StoryCardView: View {
    let storyGroup: StoryGroup
    let stories: [StoryGroup]
    @Binding var currentStoryId: String
    @Binding var showStory: Bool
    @Binding var isAnimating: Bool
    let onMarkAsSeen: (String) -> Void
    
    @StateObject private var progressDriver = StoryProgressDriver()
    @State private var currentIndex: Int = 0
    @State private var isPaused: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            ZStack {
                // Background
                Color.black
                
                // Display current story
                if storyGroup.stories.indices.contains(currentIndex) {
                    let story = storyGroup.stories[currentIndex]
                    
                    switch story.type {
                    case .image:
                        AsyncImage(url: URL(string: story.mediaURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    ProgressView()
                                        .tint(.white)
                                )
                        }
                        .frame(width: size.width, height: size.height)
                        
                    case .video:
                        if let videoURL = URL(string: story.mediaURL) {
                            VideoPlayerView(videoURL: videoURL)
                                .frame(width: size.width, height: size.height)
                        } else {
                            StoryVideoView(videoName: story.mediaURL)
                                .frame(width: size.width, height: size.height)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Tap Areas
            .overlay {
                HStack(spacing: 0) {
                    // Left tap area (30%)
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: size.width * 0.3)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            handleLeftTap()
                        }
                    
                    // Center area (40%) - pause/resume on long press
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: size.width * 0.4)
                        .contentShape(Rectangle())
                        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
                            handleLongPress(pressing: pressing)
                        }, perform: {})
                    
                    // Right tap area (30%)
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: size.width * 0.3)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            handleRightTap()
                        }
                }
                .frame(height: size.height - 120)
                .offset(y: 60)
            }
            
            // Header Overlay
            .overlay(alignment: .top) {
                VStack(spacing: 12) {
                    // Progress bars with smooth CADisplayLink animation
                    StoryProgressBar(
                        numberOfStories: storyGroup.stories.count,
                        currentIndex: currentIndex,
                        progress: progressDriver.progress
                    )
                    .padding(.horizontal)
                    
                    // Profile header
                    HStack(spacing: 13) {
                        AsyncImage(url: storyGroup.user.profileImageURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Text(String(storyGroup.user.displayName.prefix(1)))
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                )
                        }
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())

                        Text(storyGroup.user.displayName)
                            .fontWeight(.bold)
                            .foregroundColor(.white)

                        Spacer()

                        Button(action: {
                            progressDriver.stop()
                            withAnimation(.easeInOut) {
                                showStory = false
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, proxy.safeAreaInsets.top)
            }
            
            // 3D Cube rotation effect
            .rotation3DEffect(
                angle(proxy),
                axis: (x: 0, y: 1, z: 0),
                anchor: proxy.frame(in: .global).minX > 0 ? .leading : .trailing,
                perspective: 2.5
            )
        }
        .onChange(of: progressDriver.progress) { newProgress in
            if newProgress >= 1.0 && !isPaused {
                moveToNextStory()
            }
        }
        .onAppear {
            startCurrentStory()
        }
        .onDisappear {
            progressDriver.stop()
        }
    }
    
    // MARK: - Private Methods
    
    private func handleLeftTap() {
        if currentIndex > 0 {
            currentIndex -= 1
            startCurrentStory()
        } else {
            updateStoryGroup(forward: false)
        }
    }
    
    private func handleRightTap() {
        if currentIndex < storyGroup.stories.count - 1 {
            currentIndex += 1
            startCurrentStory()
        } else {
            // Mark as seen when we've viewed all stories and tap to go next
            onMarkAsSeen(storyGroup.id.uuidString)
            updateStoryGroup(forward: true)
        }
    }
    
    private func handleLongPress(pressing: Bool) {
        isPaused = pressing
        if pressing {
            progressDriver.pause()
        } else {
            progressDriver.resume()
        }
    }
    
    private func startCurrentStory() {
        guard storyGroup.stories.indices.contains(currentIndex) else { return }
        let duration = storyGroup.stories[currentIndex].duration
        progressDriver.start(duration: duration)
    }
    
    private func moveToNextStory() {
        if currentIndex < storyGroup.stories.count - 1 {
            currentIndex += 1
            startCurrentStory()
        } else {
            // Mark as seen when we've viewed all stories in the group
            print("📍 Calling onMarkAsSeen for \(storyGroup.user.username) after viewing all \(storyGroup.stories.count) stories")
            onMarkAsSeen(storyGroup.id.uuidString)
            updateStoryGroup(forward: true)
        }
    }
    
    private func updateStoryGroup(forward: Bool) {
        progressDriver.stop()
        
        guard let groupIndex = stories.firstIndex(where: { $0.id == storyGroup.id }) else { return }
        
        if forward {
            if groupIndex < stories.count - 1 {
                let nextStoryId = stories[groupIndex + 1].id.uuidString
                
                // Trigger smooth animation
                DispatchQueue.main.async {
                    StoryNavigationHandler.navigateToStory(nextStoryId, currentStoryId: self.$currentStoryId)
                }
            } else {
                // Last story group - just close
                DispatchQueue.main.async {
                    withAnimation(.easeOut(duration: 0.3)) {
                        self.showStory = false
                    }
                }
            }
        } else {
            if groupIndex > 0 {
                let prevStoryId = stories[groupIndex - 1].id.uuidString
                
                // Trigger smooth animation
                DispatchQueue.main.async {
                    StoryNavigationHandler.navigateToStory(prevStoryId, currentStoryId: self.$currentStoryId)
                }
            } else {
                currentIndex = 0
                startCurrentStory()
            }
        }
    }

    private func angle(_ proxy: GeometryProxy) -> Angle {
        let progress = proxy.frame(in: .global).minX / proxy.size.width
        let rotationAngle: CGFloat = 45
        let degrees = rotationAngle * progress
        return Angle(degrees: Double(degrees))
    }
}
