//
//  BusinessListing.swift
//  Souqira
//
//  Created on 17/02/2026
//

import Foundation

enum Currency: String, Codable {
    case usd = "usd"
    case iqd = "iqd"
    case eur = "eur"
    
    var symbol: String {
        switch self {
        case .usd: return "$"
        case .iqd: return "ع.د"
        case .eur: return "€"
        }
    }
}

enum ListingStatus: String, Codable {
    case pending = "pending"
    case approved = "approved"
    case rejected = "rejected"
}

struct Coordinates: Codable {
    let lat: Double
    let lng: Double
}

struct BusinessListing: Codable, Identifiable {
    let id: String
    let title: String
    let description: String
    let price: Double
    let currency: Currency
    let location: String  // Iraqi city (baghdad, basra, erbil, etc.)
    let category: String
    let images: [String]  // S3 URLs
    let vrMedia: [String]? // Optional VR media URLs
    let address: String?
    let coordinates: Coordinates?
    let phone: String?
    let whatsapp: String?
    let status: ListingStatus
    let saleStatus: String?  // "available" or "sold"
    let views: Int
    let isFeatured: Bool?
    let owner: ListingUser
    let createdAt: Date
    let updatedAt: Date?
    let vrPanoramaUrl: String?
    let vrVideoUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case description
        case price
        case currency
        case location
        case category
        case images
        case vrMedia
        case address
        case coordinates
        case phone
        case whatsapp
        case status
        case saleStatus
        case views
        case isFeatured
        case owner
        case createdAt
        case updatedAt
        case vrPanoramaUrl
        case vrVideoUrl
    }
    
    var formattedPrice: String {
        if price == 0 {
            return "Price on request"
        }
        
        let priceValue = Int(price)
        let symbol = currency.symbol
        
        // Format large numbers with K/M abbreviations
        if priceValue >= 1_000_000 {
            let millions = Double(priceValue) / 1_000_000.0
            if millions.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(symbol)\(Int(millions))M"
            } else {
                return String(format: "\(symbol)%.1fM", millions)
            }
        } else if priceValue >= 1_000 {
            let thousands = Double(priceValue) / 1_000.0
            if thousands.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(symbol)\(Int(thousands))K"
            } else {
                return String(format: "\(symbol)%.1fK", thousands)
            }
        } else {
            return "\(symbol)\(priceValue)"
        }
    }
    
    var primaryImage: String {
        images.first ?? ""
    }
    
    var isSold: Bool {
        saleStatus == "sold"
    }
    
    // Compatibility getters
    var user: ListingUser { owner }
    var favorites: Int { 0 }
}

struct ListingUser: Codable {
    let id: String
    let isVerified: Bool?
    let name: String?
    let email: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case isVerified
        case name
        case email
    }
}
