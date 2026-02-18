//
//  CleanHomeView.swift
//  Souqira
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
            ZStack {
                LinearGradient(colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05), Color.white], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        heroSection
                        searchAndFilterSection.padding(.horizontal).padding(.top, 24)
                        listingsSection.padding(.top, 32)
                    }
                }
            }
            .navigationTitle("Souqira")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettingsSheet = true }) {
                        Image(systemName: "gearshape.fill").font(.title3).foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                }
            }
            .sheet(isPresented: $showFilters) { FilterView(viewModel: viewModel) }
            .sheet(isPresented: $showSettingsSheet) { SettingsSheet() }
            .task {
                if viewModel.listings.isEmpty {
                    await viewModel.fetchListings(refresh: true)
                }
            }
        }
    }
    
    private var heroSection: some View {
        ZStack(alignment: .center) {
            LinearGradient(gradient: Gradient(stops: [.init(color: Color(red: 0.2, green: 0.4, blue: 0.95), location: 0), .init(color: Color(red: 0.6, green: 0.2, blue: 0.8), location: 0.6), .init(color: Color(red: 0.95, green: 0.3, blue: 0.5), location: 1)]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            
            VStack(spacing: 0) {
                Circle().fill(Color.white.opacity(0.15)).frame(width: 300, height: 300).offset(x: -100, y: -150)
                Spacer()
            }
            
            Circle().fill(Color.white.opacity(0.1)).frame(width: 250, height: 250).offset(x: 150, y: 180)
            
            VStack(spacing: 24) {
                ZStack {
                    Circle().fill(Color.white.opacity(0.25)).frame(width: 110, height: 110).blur(radius: 35)
                    Circle().fill(Color.white.opacity(0.15)).frame(width: 95, height: 95)
                    Image(systemName: "building.2.fill").font(.system(size: 50, weight: .bold)).foregroundStyle(LinearGradient(colors: [.white, .white.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing))
                }
                
                VStack(spacing: 16) {
                    Text(LocalizationManager.heroTitle.get(language: appSettings.language))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(LocalizationManager.heroSubtitle.get(language: appSettings.language))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 20)
                
                Button(action: { showSettingsSheet = true }) {
                    HStack(spacing: 14) {
                        Image(systemName: "plus.circle.fill").font(.system(size: 20, weight: .bold))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(LocalizationManager.createAd.get(language: appSettings.language)).font(.system(size: 17, weight: .bold))
                            Text("Start selling").font(.system(size: 11, weight: .medium)).opacity(0.85)
                        }
                        Spacer()
                        Image(systemName: "arrow.right.circle.fill").font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 26)
                    .padding(.vertical, 18)
                    .background(LinearGradient(gradient: Gradient(colors: [Color(red: 1.0, green: 0.4, blue: 0.3), Color(red: 0.95, green: 0.2, blue: 0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(18)
                    .shadow(color: Color(red: 1.0, green: 0.4, blue: 0.3).opacity(0.5), radius: 24, x: 0, y: 12)
                }
                .padding(.bottom, 20)
            }
        }
        .frame(height: 440)
    }
    
    private var searchAndFilterSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass").font(.system(size: 18, weight: .semibold)).foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                TextField(LocalizationManager.searchBusinesses.get(language: appSettings.language), text: $viewModel.searchQuery).textFieldStyle(.plain).font(.system(size: 16))
                if !viewModel.searchQuery.isEmpty {
                    Button(action: { viewModel.searchQuery = ""; Task { await viewModel.fetchListings(refresh: true) } }) {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 16)).foregroundColor(.gray)
                    }
                }
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
            
            Button(action: { showFilters = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "slider.horizontal.3").font(.system(size: 16, weight: .semibold))
                    Text(LocalizationManager.filters.get(language: appSettings.language)).font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue)
                .cornerRadius(10)
            }
        }
    }
    
    private var listingsSection: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading && viewModel.listings.isEmpty {
                ProgressView().frame(maxWidth: .infinity).padding(.vertical, 40)
            } else if viewModel.listings.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "building.2.fill").font(.system(size: 60)).foregroundStyle(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Text("No listings").font(.system(size: 18, weight: .semibold))
                    Text("Check back later").font(.system(size: 14)).foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 80)
            } else {
                LazyVStack(spacing: 14, pinnedViews: []) {
                    ForEach(viewModel.listings) { listing in
                        NavigationLink(destination: ListingDetailView(listing: listing)) {
                            ListingCard(listing: listing)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                if viewModel.hasMorePages {
                    ProgressView()
                        .padding(.vertical, 24)
                        .onAppear {
                            Task {
                                await viewModel.fetchListings()
                            }
                        }
                }
            }
        }
        .padding(.bottom, 40)
    }
}

#Preview {
    CleanHomeView()
        .environmentObject(AuthenticationViewModel())
        .environmentObject(AppSettings())
}
