//
//  MainTabView.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // TODO: HomeView
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                        .environment(\.symbolVariants, .none)
                }
                .tag(0)
            
            // MARK: - BONUS - just for the UI to be close to Instagram UI
            
            // TODO: SearchView
            Text("SearchView")
                .tabItem {
                    Image(systemName: "magnifyingglass")
                        .environment(\.symbolVariants, .none)
                }
                .tag(1)

            
            // TODO: CreateView
            Text("CreateView - UI BONUS")
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "plus.app.fill" : "plus.app")
                        .environment(\.symbolVariants, .none)
                }
                .tag(2)

            
            // TODO: ReelsView
            Text("ReelsView - UI BONUS")
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "play.square.fill" : "play.square")
                        .environment(\.symbolVariants, .none)
                }
                .tag(3)
 
            
            // TODO: ProfileView
            Text("ProfileView - UI BONUS")
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "person.fill" : "person.circle")
                        .environment(\.symbolVariants, .none)
                }
                .tag(4)
        }
        .accentColor(.primary)
        .onAppear {
            setupTabBarAppearance()
        }
    }
    
    private func setupTabBarAppearance() {
        // Instagram style tab bar
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.shadowColor = UIColor.separator
        
        // Configure item appearance
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor.label
        itemAppearance.selected.iconColor = UIColor.label
        
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Remove tab bar titles (Instagram style)
        UITabBarItem.appearance().setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 0.1)
        ], for: .normal)
    }
}
