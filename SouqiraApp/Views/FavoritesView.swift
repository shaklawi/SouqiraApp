//
//  FavoritesView.swift
//  Souqira
//
//  Created on 17/02/2026
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var appSettings: AppSettings
    @State private var favorites: [BusinessListing] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let apiService = APIService()
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView()
                } else if favorites.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 16) {
                            ForEach(favorites) { listing in
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
            }
            .navigationTitle(LocalizationManager.favorites.get(language: appSettings.language))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await loadFavorites()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                await loadFavorites()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(LocalizationManager.noFavoritesYet.get(language: appSettings.language))
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(LocalizationManager.startAddingFavorites.get(language: appSettings.language))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private func loadFavorites() async {
        isLoading = true
        errorMessage = nil
        
        do {
            favorites = try await apiService.fetchFavorites()
        } catch {
            errorMessage = "Failed to load favorites"
        }
        
        isLoading = false
    }
}

#Preview {
    FavoritesView()
        .environmentObject(AuthenticationViewModel())
}
