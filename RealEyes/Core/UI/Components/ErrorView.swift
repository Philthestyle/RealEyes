//
//  ErrorView.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI

struct ErrorView: View {
    let title: String
    let message: String?
    let systemImage: String
    let onRetry: (() -> Void)?
    
    init(
        title: String = "Something went wrong",
        message: String? = nil,
        systemImage: String = "exclamationmark.triangle",
        onRetry: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.onRetry = onRetry
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 50))
                .foregroundColor(.red.opacity(0.8))
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let message = message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
            }
            
            if let onRetry = onRetry {
                Button(action: onRetry) {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .font(.system(size: 16, weight: .semibold))
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
}
