//
//  User.swift
//  Souqira
//
//  Created on 17/02/2026
//

import Foundation

enum UserRole: String, Codable {
    case user = "user"
    case admin = "admin"
}

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let username: String?
    let firstName: String?
    let lastName: String?
    let phone: String?
    let whatsapp: String?
    let role: UserRole
    let emailVerified: Bool
    let profilePicture: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
        case username
        case firstName
        case lastName
        case phone
        case whatsapp
        case role
        case emailVerified = "isEmailVerified"
        case profilePicture
        case createdAt
    }
}

// API Response structures
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let message: String?
    let error: String?
}

struct AuthResponse: Codable {
    let user: User
    let accessToken: String
    let refreshToken: String
}

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
}

struct ListingsResponse: Codable {
    let listings: [BusinessListing]
    let total: Int
    let filters: ListingsFilters?
}

struct ListingsFilters: Codable {
    let page: Int
    let limit: Int
}

struct MessageResponse: Codable {
    let message: String
}

// Auth request structures
struct RegisterRequest: Codable {
    let name: String
    let email: String
    let password: String
    let phone: String
    let agreeToTerms: Bool
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct GoogleLoginRequest: Codable {
    let idToken: String

    enum CodingKeys: String, CodingKey {
        case idToken = "token"
    }
}
