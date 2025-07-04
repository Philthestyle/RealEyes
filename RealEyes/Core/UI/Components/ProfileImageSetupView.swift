//
//  ProfileImageSetupView.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI
import AVFoundation
import Photos

struct ProfileImageSetupView: View {
    @StateObject private var profileManager = ProfileImageManager.shared
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var tempImage: UIImage?
    @Environment(\.dismiss) var dismiss
    
    var isUpdating: Bool {
        profileManager.hasProfileImage
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text(isUpdating ? "Update Profile Picture" : "Add Profile Picture")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(isUpdating ? "Choose a new profile picture" : "Add a profile picture so your friends can recognize you")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Profile image preview
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 150, height: 150)
                    
                    if let image = tempImage ?? profileManager.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                    }
                    
                    // Edit button
                    Button(action: showOptions) {
                        ZStack {
                            Circle()
                                .fill(Color.black)
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "camera.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        }
                    }
                    .offset(x: 50, y: 50)
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    if tempImage != nil {
                        Button(action: saveAndContinue) {
                            Text("Use This Photo")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        
                        Button(action: { tempImage = nil }) {
                            Text("Choose Different Photo")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                    } else {
                        Button(action: showOptions) {
                            Text(isUpdating ? "Change Photo" : "Add Photo")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    
                    Button(action: isUpdating ? dismiss.callAsFunction : skipSetup) {
                        Text(isUpdating ? "Cancel" : "Skip for Now")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 40)
            }
            .padding(.vertical, 40)
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $tempImage, sourceType: imagePickerSource)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $tempImage, sourceType: .camera)
        }
        .confirmationDialog("Choose Photo", isPresented: $profileManager.showActionSheet) {
            Button("Take Photo") {
                checkCameraPermission()
            }
            Button("Choose from Library") {
                checkPhotoLibraryPermission()
            }
            if isUpdating && profileManager.hasProfileImage {
                Button("Remove Current Photo", role: .destructive) {
                    profileManager.removeProfileImage()
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func showOptions() {
        profileManager.showActionSheet = true
    }
    
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            showCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.showCamera = true
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert(for: "Camera")
        @unknown default:
            break
        }
    }
    
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            imagePickerSource = .photoLibrary
            showImagePicker = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                if status == .authorized || status == .limited {
                    DispatchQueue.main.async {
                        self.imagePickerSource = .photoLibrary
                        self.showImagePicker = true
                    }
                }
            }
        case .denied, .restricted:
            showPermissionAlert(for: "Photos")
        @unknown default:
            break
        }
    }
    
    private func showPermissionAlert(for feature: String) {
        // In a real app, show an alert directing user to Settings
    }
    
    private func saveAndContinue() {
        if let image = tempImage {
            profileManager.saveProfileImage(image)
            dismiss()
        }
    }
    
    private func skipSetup() {
        dismiss()
    }
}
