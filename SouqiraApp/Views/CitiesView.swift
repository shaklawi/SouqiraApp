//
//  CitiesView.swift
//  Souqira
//
//  Created on 17/02/2026
//

import SwiftUI

struct CitiesView: View {
    @StateObject private var viewModel = ListingsViewModel()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("📍 Explore Cities")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Discover business opportunities across Iraq's major cities")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    // Cities Grid
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(viewModel.regions) { region in
                            NavigationLink(destination: CityListingsView(region: region)) {
                                CityCard(region: region)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationTitle("Cities")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CityCard: View {
    let region: Region
    
    var body: some View {
        VStack(spacing: 12) {
            Text(region.emoji)
                .font(.system(size: 60))
            
            Text(region.nameEn)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(region.nameAr)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
}

struct CityListingsView: View {
    let region: Region
    @StateObject private var viewModel = ListingsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // City Header
                VStack(spacing: 8) {
                    Text(region.emoji)
                        .font(.system(size: 60))
                    
                    Text(region.nameEn)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Business opportunities in \(region.nameEn)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Listings
                if viewModel.isLoading && viewModel.listings.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if viewModel.listings.isEmpty {
                    EmptyStateView()
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.listings) { listing in
                            NavigationLink(destination: ListingDetailView(listing: listing)) {
                                ListingCard(listing: listing)
                            }
                            .buttonStyle(.plain)
                        }
                        
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
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle(region.nameEn)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.selectedRegion = region
            await viewModel.fetchListings(refresh: true)
        }
    }
}

#Preview {
    CitiesView()
}
