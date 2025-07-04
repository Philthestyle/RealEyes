//
//  HomeModule.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation

public struct HomeModule {
    public static func register(in container: DIContainer) {
        // Home module doesn't have its own services
        // It uses Stories and Posts modules
        print("✅ Home Module registered")
    }
}
