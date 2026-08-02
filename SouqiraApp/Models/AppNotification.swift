import Foundation

enum AppNotificationType: String, Decodable {
    case listingRequest = "listing_request"
    case listingCreated = "listing_created"
    case listingSold = "listing_sold"
    case listingPriceChanged = "listing_price_changed"
    case nearbyListingCreated = "nearby_listing_created"
    case watchedListingSold = "watched_listing_sold"
    case watchedListingPriceChanged = "watched_listing_price_changed"
    case investorRequest = "investor_request"
    case listingApproved = "listing_approved"
    case listingRejected = "listing_rejected"
    case listingFavorited = "listing_favorited"
    case profileViewed = "profile_viewed"
    case messageReceived = "message_received"
    case systemMessage = "system_message"
    case verificationRequest = "verification_request"
    case verificationApproved = "verification_approved"
    case verificationRejected = "verification_rejected"
    case other

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = AppNotificationType(rawValue: rawValue) ?? .other
    }
}

struct AppNotificationMetadata: Decodable {
    let listingId: String?
    let listingTitle: String?
    let userId: String?
    let adminMessage: String?
    let saleStatus: String?
    let oldPrice: Double?
    let newPrice: Double?
    let currency: String?
}

struct AppNotification: Identifiable, Decodable {
    let id: String
    let type: AppNotificationType
    let message: String
    let isRead: Bool
    let metadata: AppNotificationMetadata?
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case type
        case message
        case isRead
        case metadata
        case createdAt
    }
}
