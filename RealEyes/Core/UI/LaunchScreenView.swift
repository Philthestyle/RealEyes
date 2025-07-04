//
//  LaunchScreenView.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false
    @State private var rotation = 0.0
    
    var body: some View {
        ZStack {
            // Black background like the image
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 50) {
                // Logo RealEyes style Instagram
                RealEyesLogoView(height: 140)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.0)
                
                // Rainbow loader
                RainbowLoader()
                    .opacity(isAnimating ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
}
