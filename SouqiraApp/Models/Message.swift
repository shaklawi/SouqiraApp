//
//  Message.swift
//  Souqira
//
//  Created on 18/02/2026
//

import Foundation

// MARK: - Conversation
struct Conversation: Identifiable, Codable {
    let id: String
    let participants: [MessageUser]
    let listing: MessageListing?
    let lastMessage: Message?
    let unreadCount: Int
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case participants
        case listing
        case lastMessage
        case unreadCount
        case createdAt
        case updatedAt
    }
}

// MARK: - Message
struct Message: Identifiable, Codable {
    let id: String
    let conversationId: String
    let senderId: String
    let receiverId: String
    let message: String
    let isRead: Bool
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case conversationId
        case senderId
        case receiverId
        case message
        case isRead
        case createdAt
    }
}

// MARK: - MessageUser
struct MessageUser: Identifiable, Codable {
    let id: String
    let name: String
    let email: String?
    let phone: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case email
        case phone
    }
}

// MARK: - MessageListing
struct MessageListing: Identifiable, Codable {
    let id: String
    let title: String
    let price: Double
    let currency: String
    let images: [String]
    
    var primaryImage: String {
        images.first ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case title
        case price
        case currency
        case images
    }
}

// MARK: - Message Request
struct SendMessageRequest: Codable {
    let receiverId: String
    let listingId: String
    let message: String
}
