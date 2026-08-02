//
//  BusinessListing.swift
//  Souqira
//
//  Created on 17/02/2026
//

import Foundation
import CoreLocation

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

struct BusinessListing: Decodable, Identifiable {
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
    let isFavorite: Bool
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
        case isFavorite
        case owner
        case createdAt
        case updatedAt
        case vrPanoramaUrl
        case vrVideoUrl
    }

    private struct FlexibleImageValue: Decodable {
        let url: String?

        private enum CodingKeys: String, CodingKey {
            case url
            case secureUrl = "secure_url"
            case image
            case src
            case location
            case path
        }

        init(from decoder: Decoder) throws {
            if let single = try? decoder.singleValueContainer().decode(String.self) {
                let trimmed = single.trimmingCharacters(in: .whitespacesAndNewlines)
                url = trimmed.isEmpty ? nil : trimmed
                return
            }

            let container = try decoder.container(keyedBy: CodingKeys.self)
            let candidates = [
                try container.decodeIfPresent(String.self, forKey: .url),
                try container.decodeIfPresent(String.self, forKey: .secureUrl),
                try container.decodeIfPresent(String.self, forKey: .image),
                try container.decodeIfPresent(String.self, forKey: .src),
                try container.decodeIfPresent(String.self, forKey: .location),
                try container.decodeIfPresent(String.self, forKey: .path)
            ]

            url = candidates
                .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
                .first(where: { !$0.isEmpty })
        }
    }

    init(
        id: String,
        title: String,
        description: String,
        price: Double,
        currency: Currency,
        location: String,
        category: String,
        images: [String],
        vrMedia: [String]?,
        address: String?,
        coordinates: Coordinates?,
        phone: String?,
        whatsapp: String?,
        status: ListingStatus,
        saleStatus: String?,
        views: Int,
        isFeatured: Bool?,
        isFavorite: Bool = false,
        owner: ListingUser,
        createdAt: Date,
        updatedAt: Date?,
        vrPanoramaUrl: String?,
        vrVideoUrl: String?
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.currency = currency
        self.location = location
        self.category = category
        self.images = images
        self.vrMedia = vrMedia
        self.address = address
        self.coordinates = coordinates
        self.phone = phone
        self.whatsapp = whatsapp
        self.status = status
        self.saleStatus = saleStatus
        self.views = views
        self.isFeatured = isFeatured
        self.isFavorite = isFavorite
        self.owner = owner
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.vrPanoramaUrl = vrPanoramaUrl
        self.vrVideoUrl = vrVideoUrl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        price = try container.decodeIfPresent(Double.self, forKey: .price) ?? 0
        currency = try container.decodeIfPresent(Currency.self, forKey: .currency) ?? .usd
        location = try container.decodeIfPresent(String.self, forKey: .location) ?? ""
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? ""
        images = Self.decodeImages(from: container)
        vrMedia = try container.decodeIfPresent([String].self, forKey: .vrMedia)
        address = try container.decodeIfPresent(String.self, forKey: .address)

        if let decodedCoordinates = try container.decodeIfPresent(Coordinates.self, forKey: .coordinates) {
            coordinates = decodedCoordinates
        } else {
            coordinates = nil
        }

        if let phoneString = try? container.decode(String.self, forKey: .phone) {
            phone = phoneString
        } else if let phoneInt = try? container.decode(Int.self, forKey: .phone) {
            phone = String(phoneInt)
        } else {
            phone = nil
        }

        if let whatsappString = try? container.decode(String.self, forKey: .whatsapp) {
            whatsapp = whatsappString
        } else if let whatsappInt = try? container.decode(Int.self, forKey: .whatsapp) {
            whatsapp = String(whatsappInt)
        } else {
            whatsapp = nil
        }
        status = try container.decodeIfPresent(ListingStatus.self, forKey: .status) ?? .approved
        saleStatus = try container.decodeIfPresent(String.self, forKey: .saleStatus)
        views = try container.decodeIfPresent(Int.self, forKey: .views) ?? 0
        isFeatured = try container.decodeIfPresent(Bool.self, forKey: .isFeatured)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false

        if let ownerObject = try? container.decode(ListingUser.self, forKey: .owner) {
            owner = ownerObject
        } else if let ownerId = try? container.decode(String.self, forKey: .owner) {
            owner = ListingUser(id: ownerId, isVerified: nil, name: nil, email: nil)
        } else {
            owner = ListingUser(id: "", isVerified: nil, name: nil, email: nil)
        }

        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        vrPanoramaUrl = try container.decodeIfPresent(String.self, forKey: .vrPanoramaUrl)
        vrVideoUrl = try container.decodeIfPresent(String.self, forKey: .vrVideoUrl)
    }

    private static func decodeImages(from container: KeyedDecodingContainer<CodingKeys>) -> [String] {
        if let imageArray = try? container.decodeIfPresent([String].self, forKey: .images) {
            return imageArray
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        }

        if let singleImage = try? container.decodeIfPresent(String.self, forKey: .images) {
            let value = singleImage.trimmingCharacters(in: .whitespacesAndNewlines)
            if !value.isEmpty {
                return [value]
            }
        }

        if let flexibleArray = try? container.decodeIfPresent([FlexibleImageValue].self, forKey: .images) {
            return flexibleArray.compactMap { $0.url }
        }

        return []
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

struct ListingUser: Decodable {
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

enum ListingLocationResolver {
    private static let countrySuffix = "Iraq"

    private static let cityCenters: [String: CLLocationCoordinate2D] = [
        "baghdad": CLLocationCoordinate2D(latitude: 33.3152, longitude: 44.3661),
        "basra": CLLocationCoordinate2D(latitude: 30.5085, longitude: 47.7804),
        "erbil": CLLocationCoordinate2D(latitude: 36.1911, longitude: 44.0094),
        "mosul": CLLocationCoordinate2D(latitude: 36.3350, longitude: 43.1189),
        "sulaymaniyah": CLLocationCoordinate2D(latitude: 35.5613, longitude: 45.4302),
        "sulaymaniya": CLLocationCoordinate2D(latitude: 35.5613, longitude: 45.4302),
        "najaf": CLLocationCoordinate2D(latitude: 31.9980, longitude: 44.3396),
        "karbala": CLLocationCoordinate2D(latitude: 32.6160, longitude: 44.0249),
        "kirkuk": CLLocationCoordinate2D(latitude: 35.4681, longitude: 44.3922),
        "duhok": CLLocationCoordinate2D(latitude: 36.8617, longitude: 42.9960),
        "ramadi": CLLocationCoordinate2D(latitude: 33.4259, longitude: 43.2993)
    ]

    static func initialCoordinate(existing: Coordinates?, location: String) -> CLLocationCoordinate2D? {
        if let existing {
            return CLLocationCoordinate2D(latitude: existing.lat, longitude: existing.lng)
        }

        return cityCoordinate(for: location)
    }

    static func cityCoordinate(for location: String) -> CLLocationCoordinate2D? {
        let key = normalizedLocationKey(location)
        return cityCenters[key]
    }

    static func resolvedCoordinate(existing: Coordinates?, address: String?, location: String) async -> CLLocationCoordinate2D? {
        if let existing {
            return CLLocationCoordinate2D(latitude: existing.lat, longitude: existing.lng)
        }

        if let geocoded = await geocode(address: address, location: location) {
            return geocoded
        }

        return cityCoordinate(for: location)
    }

    static func requestCoordinatesJSONString(existing: Coordinates?, address: String?, location: String) async -> String? {
        if let existingJSONString = coordinatesJSONString(from: existing) {
            return existingJSONString
        }

        guard let resolved = await resolvedCoordinate(existing: nil, address: address, location: location) else {
            return nil
        }

        return jsonString(for: resolved)
    }

    static func coordinatesJSONString(from coordinates: Coordinates?) -> String? {
        guard let coordinates else { return nil }
        let coordinate = CLLocationCoordinate2D(latitude: coordinates.lat, longitude: coordinates.lng)
        return jsonString(for: coordinate)
    }

    private static func geocode(address: String?, location: String) async -> CLLocationCoordinate2D? {
        let trimmedAddress = address?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trimmedLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)

        var candidates: [String] = []
        if !trimmedAddress.isEmpty && !trimmedLocation.isEmpty {
            candidates.append("\(trimmedAddress), \(trimmedLocation), \(countrySuffix)")
        }
        if !trimmedAddress.isEmpty {
            candidates.append("\(trimmedAddress), \(countrySuffix)")
        }
        if !trimmedLocation.isEmpty {
            candidates.append("\(trimmedLocation), \(countrySuffix)")
        }

        let geocoder = CLGeocoder()
        for candidate in candidates {
            do {
                let placemarks = try await geocoder.geocodeAddressString(candidate)
                if let coordinate = placemarks.first?.location?.coordinate {
                    return coordinate
                }
            } catch {
                continue
            }
        }

        return nil
    }

    private static func jsonString(for coordinate: CLLocationCoordinate2D) -> String? {
        let payload: [String: Double] = [
            "lat": coordinate.latitude,
            "lng": coordinate.longitude
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: payload),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }

        return jsonString
    }

    private static func normalizedLocationKey(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")
    }
}
