//
//  ListingsViewModel.swift
//  Souqira
//
//  Created on 17/02/2026
//

import Foundation
import SwiftUI

@MainActor
class ListingsViewModel: ObservableObject {
    private static var cachedCategories: [Category] = []
    private static var cachedRegions: [Region] = []

    @Published var listings: [BusinessListing] = []
    @Published var categories: [Category] = []
    @Published var regions: [Region] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var hasMorePages = true
    
    // Filters
    @Published var selectedCategory: Category?
    @Published var selectedRegion: Region?
    @Published var minPrice: Double = 0
    @Published var maxPrice: Double = 100000
    @Published var searchQuery: String = ""
    
    private var currentPage = 1
    private let apiService = APIService()

    init() {}
    
    func loadCategoriesAndRegions(forceRefresh: Bool = false) async {
        if !forceRefresh, !Self.cachedCategories.isEmpty, !Self.cachedRegions.isEmpty {
            categories = Self.cachedCategories
            regions = Self.cachedRegions
            return
        }

        do {
            async let fetchedCategories = apiService.fetchCategories()
            async let fetchedRegions = apiService.fetchRegions()

            let (loadedCategories, loadedRegions) = try await (fetchedCategories, fetchedRegions)
            categories = loadedCategories
            regions = loadedRegions
            Self.cachedCategories = loadedCategories
            Self.cachedRegions = loadedRegions
        } catch {
            print("Failed to load categories/regions: \(error)")
        }
    }
    
    func fetchListings(refresh: Bool = false) async {
        let previousListings = listings

        if refresh {
            currentPage = 1
        }
        
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.fetchListings(
                page: currentPage,
                category: selectedCategory?.id,
                region: selectedRegion?.id,
                minPrice: minPrice > 0 ? minPrice : nil,
                maxPrice: maxPrice < 100000 ? maxPrice : nil,
                search: searchQuery.isEmpty ? nil : searchQuery
            )
            
            if refresh {
                let hasActiveFilters = selectedCategory != nil
                    || selectedRegion != nil
                    || !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    || minPrice > 0
                    || maxPrice < 100000

                // Keep current feed if a plain pull-to-refresh returns no items.
                if response.listings.isEmpty, !previousListings.isEmpty, !hasActiveFilters {
                    listings = previousListings
                } else {
                    listings = response.listings
                }
            } else {
                listings.append(contentsOf: response.listings)
            }
            
            hasMorePages = currentPage < response.pages
            currentPage += 1
        } catch {
            errorMessage = "Failed to load listings"
        }
        
        isLoading = false
    }
    
    func applyFilters() async {
        await fetchListings(refresh: true)
    }
    
    func resetFilters() async {
        selectedCategory = nil
        selectedRegion = nil
        minPrice = 0
        maxPrice = 100000
        searchQuery = ""
        await fetchListings(refresh: true)
    }
}
