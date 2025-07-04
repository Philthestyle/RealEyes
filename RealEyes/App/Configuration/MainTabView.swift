//
//  MainTabView.swift
//  RealEyes
//
//  Created by Ptitin on 04/07/2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                        .environment(\.symbolVariants, .none)
                }
                .tag(0)
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                        .environment(\.symbolVariants, .none)
                }
                .tag(1)
            
            CreateView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "plus.app.fill" : "plus.app")
                        .environment(\.symbolVariants, .none)
                }
                .tag(2)
            
            ReelsView()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "play.square.fill" : "play.square")
                        .environment(\.symbolVariants, .none)
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "person.fill" : "person.circle")
                        .environment(\.symbolVariants, .none)
                }
                .tag(4)
        }
        .accentColor(.primary)
        .onAppear {
            setupAppearance()
        }
    }
    
    // MARK: - Setup Appearance
    private func setupAppearance() {
        // Navigation Bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = .systemBackground
        navAppearance.shadowColor = .clear
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        
        // Tab Bar
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = .systemBackground
        tabAppearance.shadowColor = .separator
        
        // Configure item appearance
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = .label
        itemAppearance.selected.iconColor = .label
        
        tabAppearance.stackedLayoutAppearance = itemAppearance
        tabAppearance.inlineLayoutAppearance = itemAppearance
        tabAppearance.compactInlineLayoutAppearance = itemAppearance
        
        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        
        // Remove tab titles (Instagram style)
        UITabBarItem.appearance().setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 0.1)
        ], for: .normal)
        
        print("✅ UI Appearance configured")
    }
}

// Placeholder views
struct SearchView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 2),
                    GridItem(.flexible(), spacing: 2),
                    GridItem(.flexible(), spacing: 2)
                ], spacing: 2) {
                    ForEach(0..<30) { index in
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        Text("Search")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct CreateView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "camera")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                
                Text("Share a moment")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Button(action: {}) {
                    Text("Open Camera")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 40)
            }
            .navigationTitle("Create")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Profile header
                    ProfileHeaderView()
                    
                    // Profile stats
                    ProfileStatsView()
                    
                    // Bio section
                    ProfileBioView()
                    
                    // Edit profile button
                    Button(action: {}) {
                        Text("Edit Profile")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    
                    // Grid/List toggle
                    ProfileContentToggle()
                    
                    Divider()
                    
                    // Posts grid
                    ProfilePostsGrid()
                }
            }
            .navigationTitle("username")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

// Profile sub-components
struct ProfileHeaderView: View {
    var body: some View {
        HStack(spacing: 30) {
            // Profile picture
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 90, height: 90)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                )
            
            // Stats
            HStack(spacing: 30) {
                VStack {
                    Text("0")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Posts")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("0")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Followers")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("0")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Following")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
}

struct ProfileStatsView: View {
    var body: some View {
        // Placeholder for stats
        EmptyView()
    }
}

struct ProfileBioView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Your Name")
                .font(.system(size: 14, weight: .semibold))
            
            Text("Bio goes here")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

struct ProfileContentToggle: View {
    @State private var selectedContent = 0
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: { selectedContent = 0 }) {
                Image(systemName: "square.grid.3x3")
                    .font(.system(size: 24))
                    .foregroundColor(selectedContent == 0 ? .primary : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            
            Button(action: { selectedContent = 1 }) {
                Image(systemName: "person.crop.square")
                    .font(.system(size: 24))
                    .foregroundColor(selectedContent == 1 ? .primary : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
        }
    }
}

struct ProfilePostsGrid: View {
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 2),
            GridItem(.flexible(), spacing: 2),
            GridItem(.flexible(), spacing: 2)
        ], spacing: 2) {
            ForEach(0..<9) { index in
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(1, contentMode: .fit)
            }
        }
        .padding(.horizontal, 2)
    }
}
