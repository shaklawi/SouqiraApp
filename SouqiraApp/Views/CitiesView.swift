//
//  CitiesView.swift
//  Souqira
//
//  Created on 17/02/2026
//

import SwiftUI

struct CitiesView: View {
    @StateObject private var viewModel = ListingsViewModel()
    @EnvironmentObject var appSettings: AppSettings
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Elegant gradient background
                LinearGradient(
                    colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Modern Header with gradient
                        VStack(spacing: 16) {
                            // Icon with gradient
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                    .shadow(color: Color.blue.opacity(0.3), radius: 12, x: 0, y: 6)
                                
                                Image(systemName: "map.fill")
                                    .font(.system(size: 36, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 24)
                            
                            Text(LocalizationManager.exploreCities.get(language: appSettings.language))
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text(LocalizationManager.discoverBusinessOpportunities.get(language: appSettings.language))
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }
                        
                        // Loading state
                        if viewModel.regions.isEmpty {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.2)
                                    .tint(.blue)
                                Text("Loading cities...")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 64)
                        } else {
                            // Modern Cities Grid (2 columns)
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(viewModel.regions) { region in
                                    NavigationLink(destination: CityListingsView(region: region)) {
                                        ModernCityCard(region: region)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 64)
                }
            }
            .navigationTitle("Cities")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ModernCityCard: View {
    let region: Region
    
    var body: some View {
        VStack(spacing: 12) {
            // Emoji with gradient background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.1),
                                Color.purple.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                
                Text(region.emoji)
                    .font(.system(size: 36))
            }
            .padding(.top, 16)
            
            VStack(spacing: 4) {
                Text(region.nameEn)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(region.nameAr)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                
                Text(region.nameKu)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary.opacity(0.8))
            }
            .multilineTextAlignment(.center)
            
            // Arrow indicator
            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 18))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.2),
                            Color.purple.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}


struct CityListingsView: View {
    let region: Region
    @StateObject private var viewModel = ListingsViewModel()
    @EnvironmentObject var appSettings: AppSettings
    
    var body: some View {
        ZStack {
            // Elegant gradient background
            LinearGradient(
                colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05), Color.white],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Listings Section (like Home page)
                    if viewModel.isLoading && viewModel.listings.isEmpty {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(.blue)
                            Text("Loading businesses...")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 64)
                    } else if viewModel.listings.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("No listings found in \(region.nameEn)")
                                .font(.system(size: 20, weight: .semibold))
                            Text("Check back later for new opportunities")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 80)
                    } else {
                        LazyVStack(spacing: 20) {
                            ForEach(viewModel.listings) { listing in
                                NavigationLink(destination: ListingDetailView(listing: listing)) {
                                    FullWidthListingCard(listing: listing)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        if viewModel.hasMorePages {
                            ProgressView()
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
                .padding(.top, 8)
                .padding(.bottom, 80)
            }
        }
        .navigationTitle(region.nameEn)
        .navigationBarTitleDisplayMode(.large)
        .task {
            viewModel.selectedRegion = region
            await viewModel.fetchListings(refresh: true)
        }
    }
}

// Full width listing card (like Home page)
struct FullWidthListingCard: View {
    let listing: BusinessListing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Large Image
            AsyncImage(url: URL(string: listing.images.first ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ZStack {
                    LinearGradient(
                        colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .frame(height: 220)
            .frame(maxWidth: .infinity)
            .clipped()
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                // Title
                Text(listing.title)
                    .font(.system(size: 17, weight: .semibold))
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                // Location
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                    Text(listing.location.capitalized)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                // Price and Views
                HStack(alignment: .center) {
                    Text(listing.formattedPrice)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Spacer()
                    
                    HStack(spacing: 5) {
                        Image(systemName: "eye.fill")
                            .font(.system(size: 11))
                        Text("\(listing.views)")
                            .font(.system(size: 13))
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

#Preview {
    CitiesView()
}
