//
//  ProfileImageManager.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI
import PhotosUI
import Combine

class ProfileImageManager: ObservableObject {
    static let shared = ProfileImageManager()
    
    @Published var profileImage: UIImage?
    @Published var showImagePicker = false
    @Published var showCamera = false
    @Published var showActionSheet = false
    
    private let userDefaults = UserDefaults.standard
    private let profileImageKey = "userProfileImage"
    private let hasSetProfileKey = "hasSetProfileImage"
    
    init() {
        loadProfileImage()
    }
    
    var hasProfileImage: Bool {
        userDefaults.bool(forKey: hasSetProfileKey)
    }
    
    func loadProfileImage() {
        if let imageData = userDefaults.data(forKey: profileImageKey),
           let image = UIImage(data: imageData) {
            self.profileImage = image
        }
    }
    
    func saveProfileImage(_ image: UIImage) {
        // Resize image to reasonable size
        let resizedImage = image.resized(to: CGSize(width: 200, height: 200))
        
        if let data = resizedImage.jpegData(compressionQuality: 0.8) {
            userDefaults.set(data, forKey: profileImageKey)
            userDefaults.set(true, forKey: hasSetProfileKey)
            self.profileImage = resizedImage
        }
    }
    
    func deleteProfileImage() {
        userDefaults.removeObject(forKey: profileImageKey)
        userDefaults.set(false, forKey: hasSetProfileKey)
        self.profileImage = nil
    }
    
    func removeProfileImage() {
        deleteProfileImage()
    }
}

// MARK: - UIImage Extension
extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let ratio = min(widthRatio, heightRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? self
    }
}
