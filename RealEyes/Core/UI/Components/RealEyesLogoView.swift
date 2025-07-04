//
//  RealEyesLogoView.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI

struct RealEyesLogoView: View {
    let height: CGFloat
    
    // Instagram gradient colors - exact match
    private let instagramGradient = LinearGradient(
        colors: [
            Color(red: 0.95, green: 0.42, blue: 0.31),    // Orange-red
            Color(red: 0.91, green: 0.31, blue: 0.48),    // Red-pink
            Color(red: 0.85, green: 0.25, blue: 0.62),    // Pink
            Color(red: 0.74, green: 0.28, blue: 0.79),    // Purple-pink
            Color(red: 0.53, green: 0.39, blue: 0.89),    // Purple-blue
            Color(red: 0.33, green: 0.52, blue: 0.92)     // Blue
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    var body: some View {
        Text("RealEyes")
            .font(.system(size: height * 0.35, weight: .bold, design: .rounded))
            .foregroundStyle(instagramGradient)
            .tracking(-1) // Slightly tighter letter spacing like Instagram
    }
}

// Preview
struct RealEyesLogoView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Different sizes
            RealEyesLogoView(height: 40)
            RealEyesLogoView(height: 60)
            RealEyesLogoView(height: 80)
            RealEyesLogoView(height: 140)
            
            // On dark background
            RealEyesLogoView(height: 100)
                .padding()
                .background(Color.black)
            
            // On white background  
            RealEyesLogoView(height: 100)
                .padding()
                .background(Color.white)
        }
        .padding()
    }
}
