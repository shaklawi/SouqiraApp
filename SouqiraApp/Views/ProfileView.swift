//
//  ProfileView.swift
//  Souqira
//
//  Created on 17/02/2026
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var appSettings: AppSettings
    @State private var myListings: [BusinessListing] = []
    @State private var isLoadingListings = false
    @State private var showLanguageSheet = false
    
    private let apiService = APIService()
    
    var body: some View {
        NavigationStack {
            List {
                // User Info Section
                if let user = authViewModel.currentUser {
                    Section {
                        HStack(spacing: 16) {
                            // Profile Image
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 60, height: 60)
                                .overlay {
                                    Text(user.name.prefix(1).uppercased())
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.name)
                                    .font(.headline)
                                
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // My Listings
                Section(LocalizationManager.myListings.get(language: appSettings.language)) {
                    NavigationLink {
                        MyListingsView(listings: myListings)
                    } label: {
                        Label {
                            HStack {
                                Text(LocalizationManager.myAds.get(language: appSettings.language))
                                Spacer()
                                if !myListings.isEmpty {
                                    Text("\(myListings.count)")
                                        .foregroundColor(.secondary)
                                }
                            }
                        } icon: {
                            Image(systemName: "square.stack.3d.up.fill")
                        }
                    }
                }
                
                // Settings
                Section(LocalizationManager.settings.get(language: appSettings.language)) {
                    Button {
                        showLanguageSheet = true
                    } label: {
                        Label {
                            HStack {
                                Text(LocalizationManager.language.get(language: appSettings.language))
                                Spacer()
                                Text(languageName)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "globe")
                        }
                    }
                    .foregroundColor(.primary)
                    
                    Toggle(isOn: $appSettings.isDarkMode) {
                        Label(LocalizationManager.darkMode.get(language: appSettings.language), systemImage: "moon.fill")
                    }
                }
                
                // Account
                Section {
                    Button(role: .destructive) {
                        authViewModel.logout()
                    } label: {
                        Label(LocalizationManager.logout.get(language: appSettings.language), systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showLanguageSheet) {
                LanguageSelectionView()
            }
            .task {
                await loadMyListings()
            }
        }
    }
    
    private var languageName: String {
        switch appSettings.language {
        case "ar":
            return "العربية"
        case "ku":
            return "کوردی"
        default:
            return "English"
        }
    }
    
    private func loadMyListings() async {
        isLoadingListings = true
        do {
            myListings = try await apiService.fetchUserListings()
        } catch {
            print("Failed to load user listings: \(error)")
        }
        isLoadingListings = false
    }
}

struct MyListingsView: View {
    let listings: [BusinessListing]
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        ScrollView {
            if listings.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "square.stack.3d.up")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text(LocalizationManager.noListingsYet.get(language: appSettings.language))
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(LocalizationManager.createFirstListing.get(language: appSettings.language))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 16) {
                    ForEach(listings) { listing in
                        NavigationLink(destination: ListingDetailView(listing: listing)) {
                            ListingCard(listing: listing)
                                .frame(height: 210)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(12)
            }
        }
        .navigationTitle(LocalizationManager.myAds.get(language: appSettings.language))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LanguageSelectionView: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss
    
    let languages = [
        ("en", "English", "🇬🇧"),
        ("ar", "العربية", "🇮🇶"),
        ("ku", "کوردی", "☀️")
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(languages, id: \.0) { code, name, flag in
                    Button {
                        appSettings.setLanguage(code)
                        dismiss()
                    } label: {
                        HStack {
                            Text(flag)
                                .font(.title2)
                            Text(name)
                                .foregroundColor(.primary)
                            Spacer()
                            if appSettings.language == code {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle(LocalizationManager.selectLanguage.get(language: appSettings.language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizationManager.done.get(language: appSettings.language)) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(AppSettings())
}
