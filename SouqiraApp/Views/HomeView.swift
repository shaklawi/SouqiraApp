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
            ZStack {
                // Elegant gradient background
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.05),
                        Color.purple.opacity(0.05),
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
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
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.yellow.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                        
                        // Hero Section
                        heroSection
                        
                        // Search & Filters
                        searchAndFilterSection
                            .padding(.horizontal)
                            .padding(.top, 24)
                        
                        // Listings Grid
                        listingsSection
                            .padding(.top, 32)
                    }
                }
            }
            .navigationTitle("Souqira")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettingsSheet = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
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
        ZStack {
            // Mesh gradient background
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.8),
                    Color.purple.opacity(0.6),
                    Color.pink.opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Floating circles decoration
            GeometryReader { geometry in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 150, height: 150)
                    .offset(x: -50, y: -30)
                
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 200, height: 200)
                    .offset(x: geometry.size.width - 100, y: geometry.size.height - 100)
            }
            
            VStack(spacing: 20) {
                // Icon with gradient
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .blur(radius: 20)
                    
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .padding(.top, 20)
                
                Text(LocalizationManager.heroTitle.get(language: appSettings.language))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                Text(LocalizationManager.heroSubtitle.get(language: appSettings.language))
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                Button(action: { showSettingsSheet = true }) {
                    HStack(spacing: 10) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text(LocalizationManager.createAd.get(language: appSettings.language))
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                    )
                }
                .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 340)
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }
    
    private var searchAndFilterSection: some View {
        VStack(spacing: 16) {
            // Modern Search Bar with glassmorphism
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                TextField(LocalizationManager.searchBusinesses.get(language: appSettings.language), text: $viewModel.searchQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16))
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
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 15, x: 0, y: 5)
            )
            
            // Filter Pills with modern design
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    Button(action: { showFilters = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 14, weight: .semibold))
                            Text(LocalizationManager.filters.get(language: appSettings.language))
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    
                    if let category = viewModel.selectedCategory {
                        modernFilterPill(text: category.nameEn, icon: "tag.fill") {
                            viewModel.selectedCategory = nil
                            Task { await viewModel.applyFilters() }
                        }
                    }
                    
                    if let region = viewModel.selectedRegion {
                        modernFilterPill(text: "\(region.emoji) \(region.nameEn)", icon: "mappin.circle.fill") {
                            viewModel.selectedRegion = nil
                            Task { await viewModel.applyFilters() }
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private func modernFilterPill(text: String, icon: String, onRemove: @escaping () -> Void) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            Text(text)
                .font(.system(size: 14, weight: .medium))
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .foregroundColor(.primary)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(Color(.systemGray6))
        )
    }
    
    private var listingsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizationManager.allBusinessListings.get(language: appSettings.language))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.primary, .primary.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text(LocalizationManager.discoverOpportunities.get(language: appSettings.language))
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            if viewModel.isLoading && viewModel.listings.isEmpty {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(.blue)
                    Text("Loading amazing businesses...")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else if viewModel.listings.isEmpty {
                EmptyStateView()
            } else {
                VStack(spacing: 20) {
                    ForEach(Array(stride(from: 0, to: viewModel.listings.count, by: 2)), id: \.self) { index in
                        HStack(spacing: 16) {
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
                .padding(.horizontal)
                
                if viewModel.hasMorePages {
                    ProgressView()
                        .scaleEffect(1.1)
                        .tint(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .onAppear {
                            Task {
                                await viewModel.fetchListings()
                            }
                        }
                }
            }
        }
        .padding(.bottom, 100) // Extra padding for tab bar
    }
}

struct EmptyStateView: View {
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "building.2")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 8) {
                Text(LocalizationManager.noListingsFound.get(language: appSettings.language))
                    .font(.system(size: 22, weight: .bold))
                
                Text(LocalizationManager.adjustFilters.get(language: appSettings.language))
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
        .padding(.horizontal, 32)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(AppSettings())
}
