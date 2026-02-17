//
//  FilterView.swift
//  Souqira
//
//  Created on 17/02/2026
//

import SwiftUI

struct FilterView: View {
    @ObservedObject var viewModel: ListingsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var categories: [Category] = []
    @State private var isLoadingCategories = false
    
    private let apiService = APIService()
    
    var body: some View {
        NavigationStack {
            Form {
                // Category Section
                Section("Category") {
                    if isLoadingCategories {
                        ProgressView()
                    } else {
                        Picker("Select Category", selection: $viewModel.selectedCategory) {
                            Text("All Categories").tag(nil as Category?)
                            ForEach(categories) { category in
                                Text(category.nameEn).tag(category as Category?)
                            }
                        }
                    }
                }
                
                // Region Section
                Section("Region") {
                    Picker("Select Region", selection: $viewModel.selectedRegion) {
                        Text("All Regions").tag(nil as Region?)
                        ForEach(viewModel.regions) { region in
                            HStack {
                                Text(region.emoji)
                                Text(region.nameEn)
                            }
                            .tag(region as Region?)
                        }
                    }
                }
                
                // Price Range Section
                Section("Price Range") {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Min: $\(Int(viewModel.minPrice))")
                            Spacer()
                            Text("Max: $\(Int(viewModel.maxPrice))")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        HStack {
                            Text("$0")
                                .font(.caption)
                            Slider(value: $viewModel.minPrice, in: 0...100000, step: 1000)
                            Text("$100K")
                                .font(.caption)
                        }
                        
                        HStack {
                            Text("$0")
                                .font(.caption)
                            Slider(value: $viewModel.maxPrice, in: 0...100000, step: 1000)
                            Text("$100K")
                                .font(.caption)
                        }
                    }
                }
                
                // Reset Section
                Section {
                    Button("Reset All Filters", role: .destructive) {
                        Task {
                            await viewModel.resetFilters()
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        Task {
                            await viewModel.applyFilters()
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
            .task {
                await loadCategories()
            }
        }
    }
    
    private func loadCategories() async {
        isLoadingCategories = true
        do {
            categories = try await apiService.fetchCategories()
        } catch {
            print("Failed to load categories: \(error)")
        }
        isLoadingCategories = false
    }
}
