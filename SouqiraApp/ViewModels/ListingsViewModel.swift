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
    
    init() {
        Task {
            await loadCategoriesAndRegions()
        }
    }
    
    func loadCategoriesAndRegions() async {
        do {
            categories = try await apiService.fetchCategories()
            regions = try await apiService.fetchRegions()
        } catch {
            print("Failed to load categories/regions: \(error)")
        }
    }
    
    func fetchListings(refresh: Bool = false) async {
        if refresh {
            currentPage = 1
            listings = []
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
                listings = response.listings
            } else {
                listings.append(contentsOf: response.listings)
            }
            
            hasMorePages = currentPage < response.pages
            currentPage += 1
            
            print("✅ Loaded \(response.listings.count) listings (page \(currentPage - 1) of \(response.pages))")
        } catch {
            print("❌ Failed to load listings: \(error)")
            errorMessage = "Failed to load listings"
            
            // If this is the first load and we have no data, still show error but listings might have mock data
            if listings.isEmpty && refresh {
                print("⚠️ No listings available")
            }
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
