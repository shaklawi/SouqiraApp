//
//  HomeView.swift
//  Souqira
//
//  Created on 17/02/2026
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = ListingsViewModel()
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var appSettings: AppSettings
    @State private var showFilters = false
    @State private var showSettingsSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Error Banner
                    if let errorMessage = viewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text(errorMessage)
                            Spacer()
                            Button("Retry") {
                                Task {
                                    await viewModel.fetchListings(refresh: true)
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(8)
                        .padding()
                    }
                    
                    // Hero Section
                    heroSection
                    
                    // Search & Filters
                    searchAndFilterSection
                        .padding()
                    
                    // Listings Grid
                    listingsSection
                }
            }
            .navigationTitle("Souqira")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettingsSheet = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
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
    
    private var heroSection: some View {
        VStack(spacing: 16) {
            Text(LocalizationManager.heroTitle.get(language: appSettings.language))
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal)
            
            Text(LocalizationManager.heroSubtitle.get(language: appSettings.language))
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: { showSettingsSheet = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text(LocalizationManager.createAd.get(language: appSettings.language))
                        .fontWeight(.semibold)
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(25)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    private var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField(LocalizationManager.searchBusinesses.get(language: appSettings.language), text: $viewModel.searchQuery)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        Task {
                            await viewModel.applyFilters()
                        }
                    }
                
                if !viewModel.searchQuery.isEmpty {
                    Button(action: {
                        viewModel.searchQuery = ""
                        Task {
                            await viewModel.applyFilters()
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    Button(action: { showFilters = true }) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                            Text(LocalizationManager.filters.get(language: appSettings.language))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                    }
                    
                    if let category = viewModel.selectedCategory {
                        filterPill(text: category.nameEn) {
                            viewModel.selectedCategory = nil
                            Task { await viewModel.applyFilters() }
                        }
                    }
                    
                    if let region = viewModel.selectedRegion {
                        filterPill(text: "\(region.emoji) \(region.nameEn)") {
                            viewModel.selectedRegion = nil
                            Task { await viewModel.applyFilters() }
                        }
                    }
                }
            }
        }
    }
    
    private func filterPill(text: String, onRemove: @escaping () -> Void) -> some View {
        HStack {
            Text(text)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.systemGray5))
        .cornerRadius(16)
    }
    
    private var listingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(LocalizationManager.allBusinessListings.get(language: appSettings.language))
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            Text(LocalizationManager.discoverOpportunities.get(language: appSettings.language))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            if viewModel.isLoading && viewModel.listings.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            } else if viewModel.listings.isEmpty {
                EmptyStateView()
            } else {
                VStack(spacing: 16) {
                    ForEach(Array(stride(from: 0, to: viewModel.listings.count, by: 2)), id: \.self) { index in
                        HStack(spacing: 12) {
                            NavigationLink(destination: ListingDetailView(listing: viewModel.listings[index])) {
                                ListingCard(listing: viewModel.listings[index])
                            }
                            .buttonStyle(.plain)
                            
                            if index + 1 < viewModel.listings.count {
                                NavigationLink(destination: ListingDetailView(listing: viewModel.listings[index + 1])) {
                                    ListingCard(listing: viewModel.listings[index + 1])
                                }
                                .buttonStyle(.plain)
                            } else {
                                Spacer()
                                    .frame(width: 180)
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                
                if viewModel.hasMorePages {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .onAppear {
                            Task {
                                await viewModel.fetchListings()
                            }
                        }
                }
            }
        }
        .padding(.vertical)
    }
}

struct EmptyStateView: View {
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(LocalizationManager.noListingsFound.get(language: appSettings.language))
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(LocalizationManager.adjustFilters.get(language: appSettings.language))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(AppSettings())
}
