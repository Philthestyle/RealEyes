//
//  RainbowLoader.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI

// Reusable Rainbow Loader Component
struct RainbowLoader: View {
    @State private var rotation = 0.0
    @State private var trimEnd = 0.1
    
    var size: CGFloat = 60
    var lineWidth: CGFloat = 4
    
    private let gradient = AngularGradient(
        colors: [
            Color(red: 0.95, green: 0.42, blue: 0.31),    // Orange-red
            Color(red: 0.91, green: 0.31, blue: 0.48),    // Red-pink
            Color(red: 0.85, green: 0.25, blue: 0.62),    // Pink
            Color(red: 0.74, green: 0.28, blue: 0.79),    // Purple-pink
            Color(red: 0.53, green: 0.39, blue: 0.89),    // Purple-blue
            Color(red: 0.33, green: 0.52, blue: 0.92),    // Blue
            Color(red: 0.33, green: 0.75, blue: 0.85),    // Cyan
            Color(red: 0.95, green: 0.42, blue: 0.31)     // Back to orange-red
        ],
        center: .center
    )
    
    var body: some View {
        ZStack {
            // Background circle (subtle)
            Circle()
                .stroke(Color.gray.opacity(0.1), lineWidth: lineWidth * 0.75)
            
            // Animated rainbow circle
            Circle()
                .trim(from: 0, to: trimEnd)
                .stroke(
                    gradient,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(rotation))
                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotation)
                .onAppear {
                    rotation = 360
                    
                    // Animate the trim for a growing effect
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        trimEnd = 0.8
                    }
                }
            
            // Inner glow effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: size / 2
                    )
                )
                .blur(radius: 10)
        }
        .frame(width: size, height: size)
    }
}

// Small version for pull to refresh
struct MiniRainbowLoader: View {
    @State private var rotation = 0.0
    
    var size: CGFloat = 30
    
    private let gradient = LinearGradient(
        colors: [
            Color(red: 0.95, green: 0.42, blue: 0.31),
            Color(red: 0.85, green: 0.25, blue: 0.62),
            Color(red: 0.53, green: 0.39, blue: 0.89),
            Color(red: 0.33, green: 0.52, blue: 0.92)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        Circle()
            .stroke(gradient, lineWidth: 3)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotation))
            .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: rotation)
            .onAppear {
                rotation = 360
            }
    }
}

// Preview
struct RainbowLoader_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            RainbowLoader()
            RainbowLoader(size: 40, lineWidth: 3)
            MiniRainbowLoader()
        }
        .padding()
        .background(Color.black)
    }
}
