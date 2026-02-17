//
//  MockDataService.swift
//  Souqira
//
//  Created on 17/02/2026
//

import Foundation

struct MockDataService {
    static let shared = MockDataService()
    
    // MARK: - Mock Owner
    static let mockOwner = ListingUser(
        id: "user1",
        isVerified: true,
        name: "Ahmed Ali",
        email: "ahmed@example.com"
    )
    
    // MARK: - Mock Listings
    static let mockListings: [BusinessListing] = [
        BusinessListing(
            id: "1",
            title: "Cozy Cafe in Erbil City Center",
            description: "Well-established cafe with loyal customer base. Prime location in downtown Erbil.",
            price: 45000,
            currency: .usd,
            location: "erbil",
            category: "restaurants_cafes",
            images: [],
            vrMedia: nil,
            address: "Main Street, Erbil City Center",
            coordinates: Coordinates(lat: 36.1911, lng: 44.0094),
            phone: "+964 770 123 4567",
            whatsapp: "+964 770 123 4567",
            status: .approved,
            saleStatus: "available",
            views: 234,
            isFeatured: false,
            owner: mockOwner,
            createdAt: Date().addingTimeInterval(-86400 * 5),
            updatedAt: Date().addingTimeInterval(-86400 * 2),
            vrPanoramaUrl: nil,
            vrVideoUrl: nil
        ),
        BusinessListing(
            id: "2",
            title: "Modern Clothing Store - Baghdad",
            description: "Boutique clothing store in upscale shopping district.",
            price: 35000,
            currency: .usd,
            location: "baghdad",
            category: "retail_stores",
            images: [],
            vrMedia: nil,
            address: "Al-Mansour, Baghdad",
            coordinates: Coordinates(lat: 33.3152, lng: 44.3661),
            phone: "+964 771 234 5678",
            whatsapp: "+964 771 234 5678",
            status: .approved,
            saleStatus: "available",
            views: 156,
            isFeatured: false,
            owner: mockOwner,
            createdAt: Date().addingTimeInterval(-86400 * 3),
            updatedAt: Date().addingTimeInterval(-86400),
            vrPanoramaUrl: nil,
            vrVideoUrl: nil
        ),
        BusinessListing(
            id: "3",
            title: "Auto Repair Shop - Sulaymaniyah",
            description: "Fully equipped auto repair shop with all necessary tools.",
            price: 28000,
            currency: .usd,
            location: "sulaymaniyah",
            category: "retail_stores",
            images: [],
            vrMedia: nil,
            address: "Industrial Area, Sulaymaniyah",
            coordinates: Coordinates(lat: 35.5569, lng: 45.4329),
            phone: "+964 772 345 6789",
            whatsapp: "+964 772 345 6789",
            status: .approved,
            saleStatus: "available",
            views: 189,
            isFeatured: false,
            owner: mockOwner,
            createdAt: Date().addingTimeInterval(-86400 * 7),
            updatedAt: Date().addingTimeInterval(-86400 * 4),
            vrPanoramaUrl: nil,
            vrVideoUrl: nil
        )
    ]
    
    // MARK: - Mock Methods
    
    func getMockListings(category: String? = nil, region: String? = nil, search: String? = nil) -> [BusinessListing] {
        var filtered = MockDataService.mockListings
        
        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }
        
        if let region = region {
            filtered = filtered.filter { $0.location == region }
        }
        
        if let search = search, !search.isEmpty {
            filtered = filtered.filter {
                $0.title.lowercased().contains(search.lowercased()) ||
                $0.description.lowercased().contains(search.lowercased())
            }
        }
        
        return filtered
    }
}
