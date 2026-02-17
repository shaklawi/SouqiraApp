//
//  CreateListingView.swift
//  Souqira
//
//  Created on 17/02/2026
//

import SwiftUI
import PhotosUI

struct CreateListingView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    @State private var price = ""
    @State private var selectedCurrency = "USD"
    @State private var selectedCategory: Category?
    @State private var selectedRegion: Region?
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var imageData: [Data] = []
    @State private var phone = ""
    @State private var whatsapp = ""
    @State private var email = ""
    
    @State private var categories: [Category] = []
    @State private var regions: [Region] = []
    @State private var isLoadingCategories = false
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    @State private var errorMessage: String?
    
    private let apiService = APIService()
    let currencies = ["USD", "IQD"]
    
    var isFormValid: Bool {
        !title.isEmpty &&
        !description.isEmpty &&
        !price.isEmpty &&
        selectedCategory != nil &&
        selectedRegion != nil &&
        !phone.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Images Section
                Section("Photos") {
                    PhotosPicker(
                        selection: $selectedImages,
                        maxSelectionCount: 5,
                        matching: .images
                    ) {
                        Label("Add Photos (up to 5)", systemImage: "photo.on.rectangle.angled")
                    }
                    
                    if !imageData.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(imageData.indices, id: \.self) { index in
                                    if let uiImage = UIImage(data: imageData[index]) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    }
                                }
                            }
                        }
                    }
                }
                .onChange(of: selectedImages) { newItems in
                    Task {
                        imageData = []
                        for item in newItems {
                            if let data = try? await item.loadTransferable(type: Data.self) {
                                imageData.append(data)
                            }
                        }
                    }
                }
                
                // Basic Info
                Section("Business Details") {
                    TextField("Title", text: $title)
                    
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(5...10)
                    
                    HStack {
                        TextField("Price", text: $price)
                            .keyboardType(.decimalPad)
                        
                        Picker("Currency", selection: $selectedCurrency) {
                            ForEach(currencies, id: \.self) { currency in
                                Text(currency).tag(currency)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                // Category & Location
                Section("Category & Location") {
                    if isLoadingCategories {
                        ProgressView()
                    } else {
                        Picker("Category", selection: $selectedCategory) {
                            Text("Select Category").tag(nil as Category?)
                            ForEach(categories) { category in
                                Text(category.nameEn).tag(category as Category?)
                            }
                        }
                        
                        Picker("Region", selection: $selectedRegion) {
                            Text("Select Region").tag(nil as Region?)
                            ForEach(regions) { region in
                                HStack {
                                    Text(region.emoji)
                                    Text(region.nameEn)
                                }
                                .tag(region as Region?)
                            }
                        }
                    }
                }
                
                // Contact Info
                Section("Contact Information") {
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                    
                    TextField("WhatsApp (optional)", text: $whatsapp)
                        .keyboardType(.phonePad)
                    
                    TextField("Email (optional)", text: $email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                }
                
                // Submit Section
                Section {
                    Button(action: submitListing) {
                        if isSubmitting {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Create Listing")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!isFormValid || isSubmitting)
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Create Listing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Success", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your listing has been created successfully!")
            }
            .task {
                await loadCategoriesAndRegions()
            }
        }
    }
    
    private func loadCategoriesAndRegions() async {
        isLoadingCategories = true
        do {
            categories = try await apiService.fetchCategories()
            regions = try await apiService.fetchRegions()
        } catch {
            print("Failed to load data: \(error)")
        }
        isLoadingCategories = false
    }
    
    private func submitListing() {
        guard isFormValid else { return }
        
        isSubmitting = true
        errorMessage = nil
        
        Task {
            do {
                // TODO: Upload images first and get URLs
                // For now, images will be empty array
                
                let request = CreateListingRequest(
                    title: title,
                    description: description,
                    price: Double(price) ?? 0,
                    currency: selectedCurrency.lowercased(),
                    location: selectedRegion?.id ?? "",
                    category: selectedCategory?.id ?? "",
                    phone: phone,
                    whatsapp: whatsapp.isEmpty ? phone : whatsapp,
                    address: "",
                    coordinates: Coordinates(lat: 0, lng: 0)
                )
                
                _ = try await apiService.createListing(request)
                showSuccessAlert = true
            } catch {
                errorMessage = "Failed to create listing. Please try again."
                print("❌ Create listing error: \(error)")
            }
            
            isSubmitting = false
        }
    }
}

#Preview {
    CreateListingView()
        .environmentObject(AuthenticationViewModel())
}
