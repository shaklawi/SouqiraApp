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
    }
    
    func fetchListingDetail(id: String) async throws -> BusinessListing {
        let response: APIResponse<BusinessListing> = try await networkManager.fetch(endpoint: "/api/listing/approved/\(id)")
        guard let data = response.data else {
            throw NetworkError.noData
        }
        return data
    }

    func fetchMyListingDetail(id: String) async throws -> BusinessListing {
        let response: APIResponse<BusinessListing> = try await networkManager.fetch(endpoint: "/api/listing/my-listings/\(id)")
        guard let data = response.data else {
            throw NetworkError.noData
        }
        return data
    }
    
    func createListing(_ listing: CreateListingRequest, images: [Data] = []) async throws -> BusinessListing {
        if images.isEmpty {
            let response: APIResponse<BusinessListing> = try await networkManager.fetch(
                endpoint: "/api/listing/create",
                method: "POST",
                body: listing
            )

            guard let data = response.data else {
                throw NetworkError.noData
            }

            return data
        }

        var parameters: [String: String] = [
            "title": listing.title,
            "description": listing.description,
            "price": String(listing.price),
            "currency": listing.currency,
            "location": listing.location,
            "category": listing.category
        ]

        if let phone = listing.phone, !phone.isEmpty { parameters["phone"] = phone }
        if let whatsapp = listing.whatsapp, !whatsapp.isEmpty { parameters["whatsapp"] = whatsapp }
        if let address = listing.address, !address.isEmpty { parameters["address"] = address }
        if let coordinates = listing.coordinates, !coordinates.isEmpty { parameters["coordinates"] = coordinates }
        if let status = listing.status, !status.isEmpty { parameters["status"] = status }
        if let saleStatus = listing.saleStatus, !saleStatus.isEmpty { parameters["saleStatus"] = saleStatus }

        let imagePayload = images.enumerated().map { index, data in
            (data: data, filename: "listing-image-\(index + 1).jpg")
        }

        let response: APIResponse<BusinessListing> = try await networkManager.uploadMultipart(
            endpoint: "/api/listing/create",
            parameters: parameters,
            images: imagePayload
        )

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
        let _: APIResponse<String> = try await networkManager.fetch(
            endpoint: "/api/listing/delete/\(id)",
            method: "DELETE"
        )
    }
    
    // MARK: - Categories & Regions
    
    func fetchCategories() async throws -> [Category] {
        // Categories must match backend exactly
        return [
            Category(id: "restaurants_cafes", nameEn: "Restaurants & Cafes", nameAr: "مطاعم وقهوة", nameKu: "چێشتخانە و چایخانە", icon: "fork.knife"),
            Category(id: "retail_stores", nameEn: "Retail Stores", nameAr: "متاجر البيع بالتجزئة", nameKu: "فرۆشگاکانی بازاڕ", icon: "bag"),
            Category(id: "auto_services", nameEn: "Auto Services", nameAr: "خدمات السيارات", nameKu: "خزمەتی موتۆرگاڵی", icon: "car"),
            Category(id: "beauty_salons", nameEn: "Beauty Salons", nameAr: "صالونات التجميل", nameKu: "خانەی جوانی", icon: "sparkles"),
            Category(id: "ecommerce_online_business", nameEn: "E-Commerce & Online", nameAr: "التجارة الإلكترونية", nameKu: "بازرگانی ئۆنلاین", icon: "globe"),
            Category(id: "it_tech", nameEn: "IT & Technology", nameAr: "تكنولوجيا والمعلومات", nameKu: "تیکنۆلۆجیا و ئیتی", icon: "laptopcomputer"),
            Category(id: "medical_health_services", nameEn: "Medical & Health", nameAr: "الطب والخدمات الصحية", nameKu: "یارمەتیی تندروستی", icon: "heart"),
            Category(id: "education_training", nameEn: "Education & Training", nameAr: "التعليم والتدريب", nameKu: "فێرکاری و ڕاهێنان", icon: "book"),
            Category(id: "real_estate_construction", nameEn: "Real Estate & Construction", nameAr: "العقارات والبناء", nameKu: "موڵکی بازرگانی و چێوا", icon: "building"),
            Category(id: "transport_logistics", nameEn: "Transport & Logistics", nameAr: "النقل واللوجستيات", nameKu: "ڕاگەیاندن و لۆجستیک", icon: "truck"),
            Category(id: "manufacturing_industry", nameEn: "Manufacturing & Industry", nameAr: "التصنيع والصناعة", nameKu: "سازدەری و سەنعە", icon: "building.2"),
            Category(id: "agriculture_food_production", nameEn: "Agriculture & Food", nameAr: "الزراعة والغذاء", nameKu: "کشتوکاڵ و خۆراک", icon: "leaf"),
            Category(id: "financial_accounting_services", nameEn: "Financial & Accounting", nameAr: "الخدمات المالية المحاسبة", nameKu: "خزمەتی داراییو موکۆۆپاڵ", icon: "banknote"),
            Category(id: "marketing_advertising", nameEn: "Marketing & Advertising", nameAr: "التسويق والإعلان", nameKu: "بازاڕسازی و بڵاوکردنەوە", icon: "megaphone"),
            Category(id: "tourism_travel", nameEn: "Tourism & Travel", nameAr: "السياحة والسفر", nameKu: "گشتتوری و گەردەوە", icon: "airplane"),
            Category(id: "freelance_services", nameEn: "Freelance Services", nameAr: "خدمات العمل الحر", nameKu: "خزمەتی بێ بەستە", icon: "person.crop.circle"),
            Category(id: "home_based_businesses", nameEn: "Home Based Business", nameAr: "أعمال منزلية", nameKu: "بچووک کاری لە ماڵ", icon: "house"),
            Category(id: "cleaning_maintenance", nameEn: "Cleaning & Maintenance", nameAr: "التنظيف والصيانة", nameKu: "پاککردن و سەلماندن", icon: "sparkles"),
            Category(id: "wholesale_distribution", nameEn: "Wholesale & Distribution", nameAr: "الجملة والتوزيع", nameKu: "فرۆشگای بەش و دابەشکردن", icon: "shippingbox"),
            Category(id: "other", nameEn: "Other", nameAr: "أخرى", nameKu: "یەکتر", icon: "questionmark"),
            Category(id: "find_a_partner", nameEn: "Find a Partner", nameAr: "ابحث عن شريك", nameKu: "بگە رێ بۆ دۆستی کار", icon: "person.2"),
            Category(id: "find_an_investor", nameEn: "Find an Investor", nameAr: "ابحث عن مستثمر", nameKu: "بگەڕێ بۆ داروپیسکرێ", icon: "chart.line.uptrend.xyaxis"),
            Category(id: "looking_to_buy_running_business", nameEn: "Buy a Running Business", nameAr: "شراء مشروع قائم", nameKu: "کڕینی کاروباری چالاک", icon: "cart"),
            Category(id: "looking_for_shop_for_sale_in_specific_location", nameEn: "Looking for an Empty Shop", nameAr: "أبحث عن محل فارغ", nameKu: "گەڕان بەدوای دوکانی بەتاڵ", icon: "mappin.and.ellipse")
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
    
    func register(name: String, email: String, password: String) async throws -> String {
        let request = RegisterRequest(name: name, email: email, password: password)
        let response: APIResponse<MessageResponse> = try await networkManager.fetch(endpoint: "/api/auth/register", method: "POST", body: request)

        if let message = response.data?.message, !message.isEmpty {
            return message
        }

        if let message = response.message, !message.isEmpty {
            return message
        }

        return "Registration successful. Please verify your email."
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

    func resendVerificationEmail(email: String) async throws -> String {
        let request = ResendVerificationRequest(email: email)
        let response: APIResponse<MessageResponse> = try await networkManager.fetch(
            endpoint: "/api/auth/resend-verification",
            method: "POST",
            body: request
        )

        if let message = response.data?.message, !message.isEmpty {
            return message
        }

        if let message = response.message, !message.isEmpty {
            return message
        }

        return "Verification email sent."
    }

    func forgotPassword(email: String) async throws -> String {
        let request = ForgotPasswordRequest(email: email)
        let response: APIResponse<MessageResponse> = try await networkManager.fetch(
            endpoint: "/api/auth/forgot-password",
            method: "POST",
            body: request
        )

        if let message = response.data?.message, !message.isEmpty {
            return message
        }

        if let message = response.message, !message.isEmpty {
            return message
        }

        return "Verification code sent."
    }

    func confirmResetCode(email: String, code: String) async throws -> String {
        let request = ConfirmResetCodeRequest(email: email, code: code)
        let response: APIResponse<MessageResponse> = try await networkManager.fetch(
            endpoint: "/api/auth/confirm-code",
            method: "POST",
            body: request
        )

        if let message = response.data?.message, !message.isEmpty {
            return message
        }

        if let message = response.message, !message.isEmpty {
            return message
        }

        return "Code confirmed successfully."
    }

    func resetPassword(email: String, newPassword: String) async throws -> String {
        let request = ResetPasswordRequest(
            email: email,
            newPassword: newPassword,
            confirmNewPassword: newPassword
        )

        let response: APIResponse<MessageResponse> = try await networkManager.fetch(
            endpoint: "/api/auth/reset-password",
            method: "POST",
            body: request
        )

        if let message = response.data?.message, !message.isEmpty {
            return message
        }

        if let message = response.message, !message.isEmpty {
            return message
        }

        return "Password reset successfully."
    }
    
    func loginWithGoogle(idToken token: String) async throws -> AuthResponse {
        let request = GoogleLoginRequest(idToken: token)
        let response: APIResponse<AuthResponse> = try await networkManager.fetch(endpoint: "/api/auth/google/token", method: "POST", body: request)
        
        guard let authData = response.data else {
            throw NetworkError.noData
        }
        
        // Store tokens in Keychain
        networkManager.setTokens(accessToken: authData.accessToken, refreshToken: authData.refreshToken)
        
        return authData
    }

    func loginWithApple(idToken token: String, userIdentifier: String, email: String?, fullName: PersonNameComponents?) async throws -> AuthResponse {
        let request = AppleLoginRequest(
            idToken: token,
            userIdentifier: userIdentifier,
            email: email,
            firstName: fullName?.givenName,
            lastName: fullName?.familyName
        )
        let response: APIResponse<AuthResponse> = try await networkManager.fetch(endpoint: "/api/auth/apple/token", method: "POST", body: request)

        guard let authData = response.data else {
            throw NetworkError.noData
        }

        networkManager.setTokens(accessToken: authData.accessToken, refreshToken: authData.refreshToken)
        return authData
    }
    
    func logout() async throws {
        // Clear tokens from Keychain
        networkManager.clearAuthToken()
    }
    
    func deleteAccount() async throws {
        let _: APIResponse<String> = try await networkManager.fetch(
            endpoint: "/api/user/delete",
            method: "PUT"
        )
        // Clear tokens from Keychain after successful deletion
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
    
    func reportListing(id: String, reason: String) async throws {
        struct ReportRequest: Encodable { let reason: String }
        let _: APIResponse<String?> = try await networkManager.fetch(
            endpoint: "/api/listing/report/\(id)",
            method: "POST",
            body: ReportRequest(reason: reason)
        )
    }

    func blockUser(id: String) async throws {
        let _: APIResponse<String?> = try await networkManager.fetch(
            endpoint: "/api/message/block/\(id)",
            method: "POST"
        )
    }

    // MARK: - Messages
    
    func getConversations() async throws -> [Conversation] {
        let response: APIResponse<[Conversation]> = try await networkManager.fetch(endpoint: "/api/message/me")
        guard let conversations = response.data else {
            throw NetworkError.noData
        }
        return conversations
    }

    func sendMessage(receiverId: String, message: String) async throws -> Message {
        let request = SendMessageRequest(receiver: receiverId, content: message)
        let response: APIResponse<Message> = try await networkManager.fetch(
            endpoint: "/api/message",
            method: "POST",
            body: request
        )
        guard let sentMessage = response.data else {
            throw NetworkError.noData
        }
        return sentMessage
    }

    func getMessages(partnerId: String) async throws -> [Message] {
        let response: APIResponse<ConversationMessagesResponse> = try await networkManager.fetch(
            endpoint: "/api/message/\(partnerId)"
        )
        guard let result = response.data else {
            throw NetworkError.noData
        }
        return result.messages
    }

    // MARK: - Notifications

    func fetchUserNotifications() async throws -> [AppNotification] {
        let response: APIResponse<[AppNotification]> = try await networkManager.fetch(endpoint: "/api/user/notifications")
        guard let notifications = response.data else {
            throw NetworkError.noData
        }
        return notifications
    }

    func markNotificationAsRead(id: String) async throws -> AppNotification {
        let response: APIResponse<AppNotification> = try await networkManager.fetch(
            endpoint: "/api/user/notifications/\(id)/read",
            method: "PUT"
        )
        guard let notification = response.data else {
            throw NetworkError.noData
        }
        return notification
    }

    func markAllNotificationsAsRead() async throws {
        let _: APIResponse<MessageResponse> = try await networkManager.fetch(
            endpoint: "/api/user/notifications/read-all",
            method: "PUT"
        )
    }

    func registerDeviceToken(_ token: String, platform: String = "ios") async throws {
        let request = DeviceTokenRequest(token: token, platform: platform)
        let _: APIResponse<MessageResponse> = try await networkManager.fetch(
            endpoint: "/api/user/device-token",
            method: "PUT",
            body: request
        )
    }

    func registerPublicDeviceToken(_ token: String, platform: String = "ios") async throws {
        let request = DeviceTokenRequest(token: token, platform: platform)
        let _: APIResponse<MessageResponse> = try await networkManager.fetch(
            endpoint: "/api/user/device-token/public",
            method: "PUT",
            body: request
        )
    }

    func unregisterDeviceToken(_ token: String) async throws {
        let request = DeviceTokenRequest(token: token, platform: "ios")
        let _: APIResponse<MessageResponse> = try await networkManager.fetch(
            endpoint: "/api/user/device-token",
            method: "DELETE",
            body: request
        )
    }

    func trackListingEngagement(
        listingId: String,
        event: ListingEngagementEvent,
        durationSec: Int? = nil
    ) async throws {
        let request = ListingEngagementRequest(event: event.rawValue, durationSec: durationSec)
        let _: APIResponse<MessageResponse> = try await networkManager.fetch(
            endpoint: "/api/listing/engagement/\(listingId)",
            method: "POST",
            body: request
        )
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
    let phone: String?
    let whatsapp: String?
    let address: String?
    let coordinates: String?
    let status: String?
    let saleStatus: String?
}

struct DeviceTokenRequest: Codable {
    let token: String
    let platform: String
}

enum ListingEngagementEvent: String {
    case viewStart = "view_start"
    case imageView = "image_view"
    case viewEnd = "view_end"
}

struct ListingEngagementRequest: Codable {
    let event: String
    let durationSec: Int?
}

struct AppleLoginRequest: Encodable {
    let idToken: String
    let userIdentifier: String
    let email: String?
    let firstName: String?
    let lastName: String?

    enum CodingKeys: String, CodingKey {
        case token
        case idToken
        case userIdentifier
        case email
        case firstName
        case lastName
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(idToken, forKey: .token)
        try container.encode(idToken, forKey: .idToken)
        try container.encode(userIdentifier, forKey: .userIdentifier)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
    }
}
