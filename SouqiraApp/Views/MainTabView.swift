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
    @State private var selectedTab: TabItem = .home
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Main content
            Group {
                switch selectedTab {
                case .home:
                    CleanHomeView()
                case .shop:
                    CitiesView()
                case .messages:
                    ConversationsView()
                case .categories:
                    FavoritesView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .environment(\.layoutDirection, appSettings.isRTL ? .rightToLeft : .leftToRight)
    }
}
