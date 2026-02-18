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
        case .home: return "house.fill"
        case .shop: return "bag.fill"
        case .messages: return "message.fill"
        case .categories: return "square.grid.2x2.fill"
        case .profile: return "person.fill"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .shop: return "Shop"
        case .messages: return "Messages"
        case .categories: return "Categories"
        case .profile: return "Profile"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.self) { tab in
                // Hide messages tab if not authenticated
                if tab == .messages && !authViewModel.isAuthenticated {
                    EmptyView()
                } else {
                    TabBarButton(
                        tab: tab,
                        selectedTab: $selectedTab,
                        animation: animation
                    )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: -4)
        )
        .padding(.horizontal, 12)
        .padding(.bottom, 6)
    }
}

struct TabBarButton: View {
    let tab: TabItem
    @Binding var selectedTab: TabItem
    let animation: Namespace.ID
    @EnvironmentObject var appSettings: AppSettings
    
    var isSelected: Bool {
        selectedTab == tab
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        }) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 52, height: 52)
                            .matchedGeometryEffect(id: "TAB", in: animation)
                    }
                    
                    Image(systemName: tab.iconName)
                        .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? .white : .secondary)
                }
                .frame(width: 52, height: 52)
                
                if isSelected {
                    Text(getLocalizedTitle(for: tab))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.blue)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
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
            return "Categories" // Add to LocalizationManager if needed
        case .profile:
            return "Profile" // Add to LocalizationManager if needed
        }
    }
}

#Preview {
    VStack {
        Spacer()
        CustomTabBar(selectedTab: .constant(.home))
            .environmentObject(AppSettings())
            .environmentObject(AuthenticationViewModel())
    }
}
