//
//  User.swift
//  Souqira
//
//  Created on 17/02/2026
//

import Foundation

enum UserRole: String, Codable {
    case user = "user"
    case investor = "investor"
    case admin = "admin"
}

struct User: Decodable, Identifiable {
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
    let createdAt: Date?
    
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
        case isUserVerified
        case profilePicture
        case createdAt
        case firstname
        case lastname
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        username = try container.decodeIfPresent(String.self, forKey: .username)

        // Backend can return either firstName/lastName or firstname/lastname.
        let camelFirst = try container.decodeIfPresent(String.self, forKey: .firstName)
        let lowerFirst = try container.decodeIfPresent(String.self, forKey: .firstname)
        firstName = camelFirst ?? lowerFirst

        let camelLast = try container.decodeIfPresent(String.self, forKey: .lastName)
        let lowerLast = try container.decodeIfPresent(String.self, forKey: .lastname)
        lastName = camelLast ?? lowerLast

        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        whatsapp = try container.decodeIfPresent(String.self, forKey: .whatsapp)
        profilePicture = try container.decodeIfPresent(String.self, forKey: .profilePicture)

        // Fallback if backend does not provide display name directly.
        if let directName = try container.decodeIfPresent(String.self, forKey: .name), !directName.isEmpty {
            name = directName
        } else if let username = username, !username.isEmpty {
            name = username
        } else if let firstName = firstName, !firstName.isEmpty {
            name = firstName
        } else {
            name = email.components(separatedBy: "@").first ?? "User"
        }

        role = try container.decodeIfPresent(UserRole.self, forKey: .role) ?? .user
        let emailVerifiedCamel = try container.decodeIfPresent(Bool.self, forKey: .emailVerified)
        let emailVerifiedLegacy = try container.decodeIfPresent(Bool.self, forKey: .isUserVerified)
        emailVerified = emailVerifiedCamel ?? emailVerifiedLegacy ?? true

        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
    }
}

// API Response structures
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let message: String?
    let error: String?
}

struct AuthResponse: Decodable {
    let user: User
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case user
        case accessToken
        case refreshToken
        case token
        case tokenadmin
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        user = try container.decode(User.self, forKey: .user)

        if let access = try container.decodeIfPresent(String.self, forKey: .accessToken),
           let refresh = try container.decodeIfPresent(String.self, forKey: .refreshToken) {
            accessToken = access
            refreshToken = refresh
            return
        }

        let userToken = try container.decodeIfPresent(String.self, forKey: .token)
        let adminToken = try container.decodeIfPresent(String.self, forKey: .tokenadmin)

        if let jwt = userToken ?? adminToken {
            accessToken = jwt
            refreshToken = jwt
            return
        }

        throw DecodingError.keyNotFound(
            CodingKeys.accessToken,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Missing login token fields in auth response"
            )
        )
    }
}

struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}

struct ListingsResponse: Decodable {
    let listings: [BusinessListing]
    let total: Int
    let filters: ListingsFilters?

    enum CodingKeys: String, CodingKey {
        case listings
        case total
        case filters
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        listings = try container.decodeIfPresent([BusinessListing].self, forKey: .listings) ?? []
        total = try container.decodeIfPresent(Int.self, forKey: .total) ?? listings.count
        filters = try container.decodeIfPresent(ListingsFilters.self, forKey: .filters)
    }
}

struct ListingsFilters: Decodable {
    let page: Int
    let limit: Int
}

struct MessageResponse: Decodable {
    let message: String
}

// Auth request structures
struct RegisterRequest: Codable {
    let username: String
    let email: String
    let password: String
    let confirmPassword: String

    init(name: String, email: String, password: String) {
        let base = name
            .lowercased()
            .replacingOccurrences(of: " ", with: ".")
            .filter { $0.isLetter || $0.isNumber || $0 == "." }

        let emailSeed = email
            .split(separator: "@")
            .first
            .map(String.init) ?? "user"

        let chosen = base.count >= 4 ? base : emailSeed
        let safe = chosen.filter { $0.isLetter || $0.isNumber || $0 == "." }
        username = safe.count >= 4 ? safe : "user\(Int(Date().timeIntervalSince1970))"
        self.email = email
        self.password = password
        self.confirmPassword = password
    }
}

struct LoginRequest: Codable {
    let email: String
    let password: String

    enum CodingKeys: String, CodingKey {
        case email = "usernameOrEmail"
        case password
    }
}

struct ResendVerificationRequest: Codable {
    let email: String
}

struct ForgotPasswordRequest: Codable {
    let email: String
}

struct ConfirmResetCodeRequest: Codable {
    let email: String
    let code: String
}

struct ResetPasswordRequest: Codable {
    let email: String
    let newPassword: String
    let confirmNewPassword: String
}

struct GoogleLoginRequest: Encodable {
    let idToken: String

    enum CodingKeys: String, CodingKey {
        case idToken = "token"
        case rawIdToken = "idToken"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(idToken, forKey: .idToken)
        try container.encode(idToken, forKey: .rawIdToken)
    }
}
