//
//  CleanHomeView.swift
//  Souqira
//
//  Created on 18/02/2026
//

import SwiftUI

struct CleanHomeView: View {
    @StateObject private var viewModel = ListingsViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var appSettings: AppSettings
    @State private var showFilters = false
    @State private var showSettingsSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Compact header
                    VStack(spacing: 16) {
                        Text(LocalizationManager.heroTitle.get(language: appSettings.language))
                            .font(.system(size: 24, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        Text(LocalizationManager.heroSubtitle.get(language: appSettings.language))
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button(action: { showSettingsSheet = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                Text(LocalizationManager.createAd.get(language: appSettings.language))
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemBackground))
                    
                    // Search
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField(LocalizationManager.searchBusinesses.get(language: appSettings.language), text: $viewModel.searchQuery)
                            .font(.system(size: 16))
                            .onSubmit {
                                Task { await viewModel.applyFilters() }
                            }
                        
                        if !viewModel.searchQuery.isEmpty {
                            Button(action: {
                                viewModel.searchQuery = ""
                                Task { await viewModel.applyFilters() }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(14)
                    .background(Color(.systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            Button(action: { showFilters = true }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "slider.horizontal.3")
                                    Text(LocalizationManager.filters.get(language: appSettings.language))
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .clipShape(Capsule())
                            }
                            
                            if let category = viewModel.selectedCategory {
                                filterChip(text: category.nameEn) {
                                    viewModel.selectedCategory = nil
                                    Task { await viewModel.applyFilters() }
                                }
                            }
                            
                            if let region = viewModel.selectedRegion {
                                filterChip(text: "\(region.emoji) \(region.nameEn)") {
                                    viewModel.selectedRegion = nil
                                    Task { await viewModel.applyFilters() }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 12)
                    
                    // Listings
                    VStack(alignment: .leading, spacing: 16) {
                        Text(LocalizationManager.allBusinessListings.get(language: appSettings.language))
                            .font(.system(size: 22, weight: .bold))
                            .padding(.horizontal, 20)
                            .padding(.top, 24)
                        
                        if viewModel.isLoading && viewModel.listings.isEmpty {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                        } else if viewModel.listings.isEmpty {
                            EmptyListingsView()
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.listings) { listing in
                                    NavigationLink(destination: ListingDetailView(listing: listing)) {
                                        ModernListingCard(listing: listing)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            if viewModel.hasMorePages {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .onAppear {
                                        Task { await viewModel.fetchListings() }
                                    }
                            }
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Souqira")
                        .font(.system(size: 20, weight: .bold))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettingsSheet = true }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 18, weight: .medium))
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterView(viewModel: viewModel)
            }
            .sheet(isPresented: $showSettingsSheet) {
                SettingsSheet()
            }
            .task {
                if viewModel.listings.isEmpty {
                    await viewModel.fetchListings(refresh: true)
                }
            }
        }
    }
    
    private func filterChip(text: String, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 6) {
            Text(text)
                .font(.system(size: 13, weight: .medium))
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 12))
            }
        }
        .foregroundColor(.primary)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .clipShape(Capsule())
    }
}

struct EmptyListingsView: View {
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(LocalizationManager.noListingsFound.get(language: appSettings.language))
                .font(.system(size: 18, weight: .semibold))
            
            Text(LocalizationManager.adjustFilters.get(language: appSettings.language))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .padding(.horizontal, 32)
    }
}

#Preview {
    CleanHomeView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(AppSettings())
}
