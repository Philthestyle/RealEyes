//
//  GradientCircleView.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI

/// Gradient circle for story items
struct GradientCircleView: View {
    let size: CGFloat
    let lineWidth: CGFloat
    let isSeen: Bool
    
    init(size: CGFloat = 75, lineWidth: CGFloat = 3, isSeen: Bool = false) {
        self.size = size
        self.lineWidth = lineWidth
        self.isSeen = isSeen
    }
    
    var body: some View {
        Circle()
            .stroke(
                isSeen ? AnyShapeStyle(Color.gray.opacity(0.3)) : AnyShapeStyle(gradient),
                lineWidth: lineWidth
            )
            .frame(width: size, height: size)
            .animation(.easeInOut(duration: 0.3), value: isSeen)
    }
    
    private var gradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.7, green: 0.0, blue: 0.8),
                Color(red: 1.0, green: 0.0, blue: 0.4),
                Color(red: 1.0, green: 0.6, blue: 0.0),
                Color(red: 1.0, green: 0.8, blue: 0.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
