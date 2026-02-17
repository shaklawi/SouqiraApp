//
//  MainTabView.swift
//  Souqira
//
//  Created on 17/02/2026
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label(LocalizationManager.home.get(language: appSettings.language), systemImage: "house.fill")
                }
                .tag(0)
            
            CitiesView()
                .tabItem {
                    Label(LocalizationManager.cities.get(language: appSettings.language), systemImage: "map.fill")
                }
                .tag(1)
            
            CreateListingView()
                .tabItem {
                    Label(LocalizationManager.createAd.get(language: appSettings.language), systemImage: "plus.circle.fill")
                }
                .tag(2)
            
            // Messages tab - only visible when logged in
            if authViewModel.isAuthenticated {
                ConversationsView()
                    .tabItem {
                        Label(LocalizationManager.messages.get(language: appSettings.language), systemImage: "message.fill")
                    }
                    .tag(3)
            }
            
            FavoritesView()
                .tabItem {
                    Label(LocalizationManager.favorites.get(language: appSettings.language), systemImage: "heart.fill")
                }
                .tag(4)
        }
        .accentColor(.blue)
        .environment(\.layoutDirection, appSettings.isRTL ? .rightToLeft : .leftToRight)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(AppSettings())
}
