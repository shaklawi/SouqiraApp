//
//  APIService.swift
//  Souqira
//
//  Created on 17/02/2026
//

import Foundation

struct APIService {
    private let networkManager = NetworkManager.shared
    private let mockDataService = MockDataService.shared
    
    // MARK: - Listings
    
    func fetchListings(
        page: Int = 1,
        category: String? = nil,
        region: String? = nil,
        minPrice: Double? = nil,
        maxPrice: Double? = nil,
        search: String? = nil
    ) async throws -> (listings: [BusinessListing], total: Int, page: Int, pages: Int) {
        // Try real API first
        do {
            var queryItems: [String] = ["page=\(page)", "limit=12"]
            
            if let category = category {
                queryItems.append("category=\(category)")
            }
            if let region = region {
                queryItems.append("location=\(region)")
            }
            if let minPrice = minPrice {
                queryItems.append("minPrice=\(Int(minPrice))")
            }
            if let maxPrice = maxPrice {
                queryItems.append("maxPrice=\(Int(maxPrice))")
            }
            if let search = search, !search.isEmpty {
                queryItems.append("search=\(search.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")
            }
            
            let query = queryItems.joined(separator: "&")
            print("📡 Fetching listings: /api/listing?\(query)")
            let response: APIResponse<ListingsResponse> = try await networkManager.fetch(endpoint: "/api/listing?\(query)")
            print("✅ Using real API data from https://api.souqira.com")
            
            guard let data = response.data else {
                print("❌ No data in response")
                throw NetworkError.noData
            }
            
            print("✅ Got \(data.listings.count) listings from API")
            
            let total = data.total
            let pages = (total + 11) / 12
            
            return (listings: data.listings, total: total, page: page, pages: pages)
        } catch {
            // Fallback to mock data if API fails
            print("⚠️ API failed, using mock data. Error: \(error)")
            if let decodingError = error as? DecodingError {
                print("🔍 Decoding error details: \(decodingError)")
            }
            let mockListings = mockDataService.getMockListings(
                category: category,
                region: region,
                search: search
            )
            
            // Filter by price if needed
            var filtered = mockListings
            if let minPrice = minPrice {
                filtered = filtered.filter { $0.price >= minPrice }
            }
            if let maxPrice = maxPrice {
                filtered = filtered.filter { $0.price <= maxPrice }
            }
            
            return (listings: filtered, total: filtered.count, page: 1, pages: 1)
        }
    }
    
    func fetchListingDetail(id: String) async throws -> BusinessListing {
        let response: APIResponse<BusinessListing> = try await networkManager.fetch(endpoint: "/api/listing/\(id)")
        guard let data = response.data else {
            throw NetworkError.noData
        }
        return data
    }
    
    func createListing(_ listing: CreateListingRequest) async throws -> BusinessListing {
        let response: APIResponse<BusinessListing> = try await networkManager.fetch(endpoint: "/api/listing/create", method: "POST", body: listing)
        guard let data = response.data else {
            throw NetworkError.noData
        }
        return data
    }
    
    func updateListing(id: String, listing: CreateListingRequest) async throws -> BusinessListing {
        let response: APIResponse<BusinessListing> = try await networkManager.fetch(endpoint: "/api/listing/update/\(id)", method: "PUT", body: listing)
        guard let data = response.data else {
            throw NetworkError.noData
        }
        return data
    }
    
    func deleteListing(id: String) async throws {
        let _: APIResponse<MessageResponse> = try await networkManager.fetch(endpoint: "/api/listing/delete/\(id)", method: "DELETE")
    }
    
    // MARK: - Categories & Regions
    
    func fetchCategories() async throws -> [Category] {
        // Using hardcoded categories as they're fixed in the backend
        return [
            Category(id: "restaurant", nameEn: "Restaurant", nameAr: "مطعم", nameKu: "چێشتخانە", icon: "fork.knife"),
            Category(id: "retail", nameEn: "Retail", nameAr: "تجزئة", nameKu: "فرۆشگا", icon: "bag"),
            Category(id: "cafe", nameEn: "Cafe", nameAr: "مقهى", nameKu: "چایخانە", icon: "cup.and.saucer"),
            Category(id: "hotel", nameEn: "Hotel", nameAr: "فندق", nameKu: "هوتێل", icon: "bed.double"),
            Category(id: "factory", nameEn: "Factory", nameAr: "مصنع", nameKu: "کارگە", icon: "building.2"),
            Category(id: "warehouse", nameEn: "Warehouse", nameAr: "مستودع", nameKu: "کۆگا", icon: "shippingbox"),
            Category(id: "office", nameEn: "Office", nameAr: "مكتب", nameKu: "نووسینگە", icon: "briefcase"),
            Category(id: "land", nameEn: "Land", nameAr: "أرض", nameKu: "زەوی", icon: "map"),
            Category(id: "building", nameEn: "Building", nameAr: "مبنى", nameKu: "بینا", icon: "building"),
            Category(id: "apartment", nameEn: "Apartment", nameAr: "شقة", nameKu: "شوقە", icon: "house"),
            Category(id: "house", nameEn: "House", nameAr: "منزل", nameKu: "خانوو", icon: "house.fill"),
            Category(id: "commercial_villa", nameEn: "Commercial Villa", nameAr: "فيلا تجارية", nameKu: "ڤیلای بازرگانی", icon: "building.columns")
        ]
    }
    
    func fetchRegions() async throws -> [Region] {
        // Using fixed Iraqi cities
        return [
            Region(id: "baghdad", nameEn: "Baghdad", nameAr: "بغداد", nameKu: "بەغدا", emoji: "🕌"),
            Region(id: "basra", nameEn: "Basra", nameAr: "البصرة", nameKu: "بەسرە", emoji: "🌊"),
            Region(id: "erbil", nameEn: "Erbil", nameAr: "أربيل", nameKu: "هەولێر", emoji: "🏛️"),
            Region(id: "mosul", nameEn: "Mosul", nameAr: "الموصل", nameKu: "موسڵ", emoji: "🏛"),
            Region(id: "sulaymaniyah", nameEn: "Sulaymaniyah", nameAr: "السليمانية", nameKu: "سلێمانی", emoji: "🌆"),
            Region(id: "najaf", nameEn: "Najaf", nameAr: "النجف", nameKu: "نەجەف", emoji: "🌟"),
            Region(id: "karbala", nameEn: "Karbala", nameAr: "كربلاء", nameKu: "کەربەلا", emoji: "✨"),
            Region(id: "kirkuk", nameEn: "Kirkuk", nameAr: "كركوك", nameKu: "کەرکووک", emoji: "🏙️"),
            Region(id: "duhok", nameEn: "Duhok", nameAr: "دهوك", nameKu: "دهۆک", emoji: "⛰️"),
            Region(id: "ramadi", nameEn: "Ramadi", nameAr: "الرمادي", nameKu: "ڕەمادی", emoji: "🏜️")
        ]
    }
    
    // MARK: - Authentication
    
    func register(name: String, email: String, password: String, phone: String, agreeToTerms: Bool) async throws -> AuthResponse {
        let request = RegisterRequest(name: name, email: email, password: password, phone: phone, agreeToTerms: agreeToTerms)
        let response: APIResponse<AuthResponse> = try await networkManager.fetch(endpoint: "/api/auth/register", method: "POST", body: request)
        
        guard let authData = response.data else {
            throw NetworkError.noData
        }
        
        // Store tokens in Keychain
        networkManager.setTokens(accessToken: authData.accessToken, refreshToken: authData.refreshToken)
        
        return authData
    }
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(email: email, password: password)
        let response: APIResponse<AuthResponse> = try await networkManager.fetch(endpoint: "/api/auth/login", method: "POST", body: request)
        
        guard let authData = response.data else {
            throw NetworkError.noData
        }
        
        // Store tokens in Keychain
        networkManager.setTokens(accessToken: authData.accessToken, refreshToken: authData.refreshToken)
        
        return authData
    }
    
    func loginWithGoogle(idToken: String) async throws -> AuthResponse {
        let request = GoogleLoginRequest(idToken: idToken)
        let response: APIResponse<AuthResponse> = try await networkManager.fetch(endpoint: "/api/auth/google", method: "POST", body: request)
        
        guard let authData = response.data else {
            throw NetworkError.noData
        }
        
        // Store tokens in Keychain
        networkManager.setTokens(accessToken: authData.accessToken, refreshToken: authData.refreshToken)
        
        return authData
    }
    
    func logout() async throws {
        let _: APIResponse<MessageResponse> = try await networkManager.fetch(endpoint: "/api/auth/logout", method: "POST")
        
        // Clear tokens from Keychain
        networkManager.clearAuthToken()
    }
    
    func getCurrentUser() async throws -> User {
        let response: APIResponse<User> = try await networkManager.fetch(endpoint: "/api/user/profile")
        guard let user = response.data else {
            throw NetworkError.noData
        }
        return user
    }
    
    // MARK: - User Profile
    
    func fetchUserListings(page: Int = 1) async throws -> [BusinessListing] {
        let response: APIResponse<ListingsResponse> = try await networkManager.fetch(endpoint: "/api/listing/my-listings?page=\(page)&limit=12")
        guard let data = response.data else {
            throw NetworkError.noData
        }
        return data.listings
    }
    
    func fetchFavorites() async throws -> [BusinessListing] {
        let response: APIResponse<[BusinessListing]> = try await networkManager.fetch(endpoint: "/api/listing/my-favorites")
        guard let favorites = response.data else {
            throw NetworkError.noData
        }
        return favorites
    }
    
    func toggleFavorite(listingId: String, isCurrentlyFavorite: Bool) async throws {
        if isCurrentlyFavorite {
            // Remove from favorites
            struct DeleteData: Codable {
                let id: String
            }
            let _: APIResponse<DeleteData> = try await networkManager.fetch(
                endpoint: "/api/listing/favorites/\(listingId)",
                method: "DELETE"
            )
        } else {
            // Add to favorites
            let _: APIResponse<[String]> = try await networkManager.fetch(
                endpoint: "/api/listing/favorites/\(listingId)",
                method: "POST"
            )
        }
    }
    
    // MARK: - Messages
    
    func getConversations() async throws -> [Conversation] {
        let response: APIResponse<[Conversation]> = try await networkManager.fetch(endpoint: "/api/message/conversations")
        guard let conversations = response.data else {
            throw NetworkError.noData
        }
        return conversations
    }
    
    func sendMessage(receiverId: String, listingId: String, message: String) async throws -> Message {
        let request = SendMessageRequest(receiverId: receiverId, listingId: listingId, message: message)
        let response: APIResponse<Message> = try await networkManager.fetch(
            endpoint: "/api/message/send",
            method: "POST",
            body: request
        )
        guard let sentMessage = response.data else {
            throw NetworkError.noData
        }
        return sentMessage
    }
    
    func getMessages(conversationId: String) async throws -> [Message] {
        let response: APIResponse<[Message]> = try await networkManager.fetch(endpoint: "/api/message/\(conversationId)")
        guard let messages = response.data else {
            throw NetworkError.noData
        }
        return messages
    }
}

// MARK: - Request Models

struct CreateListingRequest: Codable {
    let title: String
    let description: String
    let price: Double
    let currency: String
    let location: String
    let category: String
    let phone: String
    let whatsapp: String
    let address: String
    let coordinates: Coordinates
}
