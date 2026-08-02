//
//  CustomTabBar.swift
//  Souqira
//
//  Created on 18/02/2026
//

import SwiftUI

enum TabItem: Int, CaseIterable {
    case home = 0
    case shop = 1
    case messages = 2
    case categories = 3
    case profile = 4
    
    var iconName: String {
        switch self {
        case .home: return "house"
        case .shop: return "magnifyingglass"
        case .messages: return "bubble.left.and.bubble.right"
        case .categories: return "heart"
        case .profile: return "person"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .shop: return "Cities"
        case .messages: return "Messages"
        case .categories: return "Favorites"
        case .profile: return "Profile"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    var bottomSafeAreaInset: CGFloat = 0
    var onCreateListingTap: () -> Void
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var authViewModel: AuthenticationViewModel

    private let navAccent = Color(hex: "#2B7EA1")
    private let navAccentStrong = Color(hex: "#4F9DC0")

    private var navigationTabs: [TabItem] {
        if authViewModel.isAuthenticated {
            return [.home, .shop, .messages, .profile]
        }
        return [.home, .shop, .categories, .profile]
    }

    private var leftTabs: [TabItem] {
        Array(navigationTabs.prefix(2))
    }

    private var rightTabs: [TabItem] {
        Array(navigationTabs.suffix(2))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(leftTabs, id: \.self) { tab in
                        TabBarButton(tab: tab, selectedTab: $selectedTab)
                    }
                }

                Spacer(minLength: 78)

                HStack(spacing: 0) {
                    ForEach(rightTabs, id: \.self) { tab in
                        TabBarButton(tab: tab, selectedTab: $selectedTab)
                    }
                }
            }
            .padding(.top, 16)
            .padding(.bottom, max(bottomSafeAreaInset, 10))
            .padding(.horizontal, 10)
            .background(
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(hex: "#050B26"))

                    Circle()
                        .fill(Color(hex: "#050B26"))
                        .frame(width: 80, height: 80)
                        .offset(y: -40)

                    LinearGradient(
                        colors: [Color.white.opacity(0.08), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 1)
                    .frame(maxHeight: .infinity, alignment: .top)
                }
            )

            Button(action: onCreateListingTap) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 68, height: 68)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [navAccentStrong, navAccent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.8), lineWidth: 4)
                            )
                    )
                    .shadow(color: navAccent.opacity(0.42), radius: 14, x: 0, y: 8)
                    .offset(y: -34)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .zIndex(1000)
    }
}

struct TabBarButton: View {
    let tab: TabItem
    @Binding var selectedTab: TabItem
    @EnvironmentObject var appSettings: AppSettings

    private let navAccent = Color(hex: "#4F9DC0")
    
    var isSelected: Bool {
        selectedTab == tab
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.18)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? navAccent : Color.white.opacity(0.62))
                    .frame(width: 28, height: 24)

                Text(getLocalizedTitle(for: tab))
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .white : Color.white.opacity(0.62))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .allowsTightening(true)
                    .frame(maxWidth: .infinity)

                Capsule()
                    .fill(isSelected ? navAccent : Color.clear)
                    .frame(width: 16, height: 2)
            }
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var iconName: String {
        if !isSelected {
            return tab.iconName
        }

        switch tab {
        case .home: return "house.fill"
        case .shop: return "magnifyingglass"
        case .messages: return "bell.fill"
        case .categories: return "heart.fill"
        case .profile: return "person.fill"
        }
    }
    
    func getLocalizedTitle(for tab: TabItem) -> String {
        switch tab {
        case .home:
            return LocalizationManager.home.get(language: appSettings.language)
        case .shop:
            return LocalizationManager.cities.get(language: appSettings.language)
        case .messages:
            return LocalizationManager.messages.get(language: appSettings.language)
        case .categories:
            return LocalizationManager.favorites.get(language: appSettings.language)
        case .profile:
            if appSettings.language == "ar" {
                return "الملف"
            }
            return LocalizationManager.profile.get(language: appSettings.language)
        }
    }
}

#Preview {
    VStack {
        Spacer()
        CustomTabBar(
            selectedTab: .constant(.home),
            bottomSafeAreaInset: 22,
            onCreateListingTap: {}
        )
            .environmentObject(AppSettings())
            .environmentObject(AuthenticationViewModel())
    }
}
