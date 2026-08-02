//
//  Message.swift
//  Souqira
//
//  Created on 18/02/2026
//

import Foundation

// MARK: - Conversation
// Matches backend: GET /api/message/me → { _id, partner, latestMessage }
struct Conversation: Identifiable, Decodable {
    let id: String          // partner user id (used as unique conversation key)
    let partner: MessageUser
    let latestMessage: Message

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case partner
        case latestMessage
    }
}

// MARK: - Message
// Matches backend: { _id, sender, receiver, content, isRead, createdAt }
struct Message: Identifiable, Decodable {
    let id: String
    let senderId: String
    let receiverId: String
    let content: String
    let isRead: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case senderId = "sender"
        case receiverId = "receiver"
        case content
        case isRead
        case createdAt
    }
}

// MARK: - MessageUser
// Matches backend partner projection: { _id, username, email, firstname, lastname, role }
struct MessageUser: Identifiable, Decodable {
    let id: String
    let email: String?
    let firstname: String?
    let lastname: String?
    let username: String?

    var name: String {
        let full = [firstname, lastname].compactMap { $0 }.joined(separator: " ")
        if !full.trimmingCharacters(in: .whitespaces).isEmpty { return full }
        return username ?? email?.components(separatedBy: "@").first ?? id
    }

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case email
        case firstname
        case lastname
        case username
    }
}

// MARK: - Conversation Messages Response
// Matches: GET /api/message/:userId → { messages, total, page, limit, userInfo }
struct ConversationMessagesResponse: Decodable {
    let messages: [Message]
    let total: Int
    let page: Int
    let limit: Int
    let userInfo: ConversationUserInfo
}

struct ConversationUserInfo: Decodable {
    let otherUserId: String
    let firstname: String?
    let lastname: String?
    let otherEmail: String?
}

// MARK: - Send Message Request
// Matches: POST /api/message  { receiver, content }
struct SendMessageRequest: Encodable {
    let receiver: String
    let content: String
}
