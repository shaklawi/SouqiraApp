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
    @State private var showCreateListingSheet = false
    @State private var showAuthSheet = false

    private var bottomSafeAreaInset: CGFloat {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            return 0
        }
        return window.safeAreaInsets.bottom
    }

    private var availableNavigationTabs: [TabItem] {
        if authViewModel.isAuthenticated {
            return [.home, .shop, .messages, .profile]
        }
        return [.home, .shop, .categories, .profile]
    }

    private func normalizeSelectedTab() {
        if !availableNavigationTabs.contains(selectedTab) {
            selectedTab = .home
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            CleanHomeView()
                .tag(TabItem.home)

            CitiesView()
                .tag(TabItem.shop)

            ConversationsView()
                .tag(TabItem.messages)

            FavoritesView()
                .tag(TabItem.categories)

            ProfileView()
                .tag(TabItem.profile)
        }
        .toolbar(.hidden, for: .tabBar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            CustomTabBar(
                selectedTab: $selectedTab,
                bottomSafeAreaInset: bottomSafeAreaInset,
                onCreateListingTap: {
                    if authViewModel.isAuthenticated {
                        showCreateListingSheet = true
                    } else {
                        showAuthSheet = true
                    }
                }
            )
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
            .onAppear {
                normalizeSelectedTab()
            }
            .onChange(of: authViewModel.isAuthenticated) { _ in
                normalizeSelectedTab()
            }
            .sheet(isPresented: $showCreateListingSheet) { CreateListingView() }
            .sheet(isPresented: $showAuthSheet) { AuthenticationView() }
        .environment(\.layoutDirection, appSettings.isRTL ? .rightToLeft : .leftToRight)
    }
}
