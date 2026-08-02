import Foundation
import UserNotifications
import UIKit

@MainActor
final class AppNotificationManager: ObservableObject {
    @Published private(set) var notifications: [AppNotification] = []
    @Published private(set) var unreadCount: Int = 0

    private let apiService = APIService()
    private var lastUnreadIds: Set<String> = []
    private var hasPrimed = false

    private var currentLanguage: String {
        let storedLanguage = UserDefaults.standard.string(forKey: "appLanguage")?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !storedLanguage.isEmpty {
            return storedLanguage
        }

        if let languageCode = Locale.preferredLanguages.first?.lowercased() {
            if languageCode.hasPrefix("ar") {
                return "ar"
            }
            if languageCode.hasPrefix("ku") || languageCode.hasPrefix("ckb") {
                return "ku"
            }
        }

        return "en"
    }

    func pollingLoop() async {
        while !Task.isCancelled {
            await refreshNotifications()
            try? await Task.sleep(nanoseconds: 20_000_000_000)
        }
    }

    func refreshNotifications() async {
        guard NetworkManager.shared.accessToken != nil else {
            reset()
            return
        }

        do {
            let fetched = try await apiService.fetchUserNotifications()
            notifications = fetched

            let unread = fetched.filter { !$0.isRead }
            unreadCount = unread.count
            UIApplication.shared.applicationIconBadgeNumber = unreadCount

            if hasPrimed {
                for notification in unread where !lastUnreadIds.contains(notification.id) {
                    postLocalNotification(notification)
                }
            }

            lastUnreadIds = Set(unread.map { $0.id })
            hasPrimed = true
        } catch {
            print("❌ Failed to fetch notifications: \(error)")
        }
    }

    func reset() {
        notifications = []
        unreadCount = 0
        lastUnreadIds = []
        hasPrimed = false
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    private func postLocalNotification(_ notification: AppNotification) {
        let content = UNMutableNotificationContent()
        content.title = title(for: notification)
        content.body = notification.message
        content.sound = .default
        content.badge = NSNumber(value: unreadCount)

        let request = UNNotificationRequest(
            identifier: "app-notification-\(notification.id)",
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("❌ Local notification scheduling failed: \(error)")
            }
        }
    }

    private func title(for notification: AppNotification) -> String {
        let listingTitle = notification.metadata?.listingTitle?.trimmingCharacters(in: .whitespacesAndNewlines)
        let language = currentLanguage

        switch notification.type {
        case .listingRequest:
            return listingTitle.map {
                localizedListingTitle(
                    prefixEn: "Listing Request",
                    arTemplate: "تم استلام طلب الإعلان الخاص بـ %@",
                    kuTemplate: "داواکاری ڕیکلامی %@ وەرگیرا",
                    title: $0,
                    language: language
                )
            }
                ?? localizedText(en: "Listing Request", ar: "طلب الإعلان", ku: "داواکاری ڕیکلام", language: language)
        case .listingCreated:
            return listingTitle.map {
                localizedListingTitle(
                    prefixEn: "New Listing",
                    arTemplate: "تم نشر إعلان جديد بعنوان %@",
                    kuTemplate: "ڕیکلامێکی نوێ بڵاوکرایەوە بە ناوی %@",
                    title: $0,
                    language: language
                )
            }
                ?? localizedText(en: "New Listing", ar: "إعلان جديد", ku: "ڕیکلامی نوێ", language: language)
        case .nearbyListingCreated:
            return listingTitle.map {
                localizedListingTitle(
                    prefixEn: "Nearby Listing",
                    arTemplate: "إعلان جديد في منطقتك: %@",
                    kuTemplate: "ڕیکلامێکی نوێ لە ناوچەکەت: %@",
                    title: $0,
                    language: language
                )
            }
                ?? localizedText(en: "Nearby Listing", ar: "إعلان قريب منك", ku: "ڕیکلامی نزیک", language: language)
        case .listingSold:
            return listingTitle.map {
                localizedListingTitle(
                    prefixEn: "Sold",
                    arTemplate: "تم بيع %@",
                    kuTemplate: "%@ فرۆشرا",
                    title: $0,
                    language: language
                )
            }
                ?? localizedText(en: "Listing Sold", ar: "تم بيع الإعلان", ku: "ڕیکلامەکە فرۆشرا", language: language)
        case .watchedListingSold:
            return listingTitle.map {
                localizedListingTitle(
                    prefixEn: "Viewed Listing Sold",
                    arTemplate: "إعلان شاهدته تم بيعه: %@",
                    kuTemplate: "ڕیکلامێک کە بینیوتە فرۆشرا: %@",
                    title: $0,
                    language: language
                )
            }
                ?? localizedText(en: "Viewed Listing Sold", ar: "تم بيع إعلان شاهدته", ku: "ڕیکلامێک کە بینیوتە فرۆشرا", language: language)
        case .listingPriceChanged, .watchedListingPriceChanged:
            return listingTitle.map {
                localizedListingTitle(
                    prefixEn: "Price Changed",
                    arTemplate: "تم تغيير سعر %@",
                    kuTemplate: "نرخی %@ گۆڕدرا",
                    title: $0,
                    language: language
                )
            }
                ?? localizedText(en: "Price Changed", ar: "تغيير في السعر", ku: "گۆڕانی نرخ", language: language)
        case .investorRequest:
            return localizedText(en: "Investor Update", ar: "تحديث المستثمر", ku: "نوێکاری وەبەرهێنەر", language: language)
        case .messageReceived:
            return localizedText(en: "New Message", ar: "رسالة جديدة", ku: "نامەی نوێ", language: language)
        case .listingFavorited:
            return listingTitle.map {
                localizedListingTitle(
                    prefixEn: "Saved",
                    arTemplate: "تم حفظ الإعلان %@",
                    kuTemplate: "ڕیکلامی %@ پاشەکەوت کرا",
                    title: $0,
                    language: language
                )
            }
                ?? localizedText(en: "New Favorite", ar: "حفظ جديد", ku: "دڵخوازیی نوێ", language: language)
        case .listingApproved:
            return listingTitle.map {
                localizedListingTitle(
                    prefixEn: "Approved",
                    arTemplate: "تمت الموافقة على %@",
                    kuTemplate: "%@ پەسەندکرا",
                    title: $0,
                    language: language
                )
            }
                ?? localizedText(en: "Listing Approved", ar: "تمت الموافقة على الإعلان", ku: "ڕیکلامەکە پەسەندکرا", language: language)
        case .listingRejected:
            return listingTitle.map {
                localizedListingTitle(
                    prefixEn: "Update",
                    arTemplate: "تم تحديث حالة %@",
                    kuTemplate: "دۆخی %@ نوێکرایەوە",
                    title: $0,
                    language: language
                )
            }
                ?? localizedText(en: "Listing Update", ar: "تحديث الإعلان", ku: "نوێکاری ڕیکلام", language: language)
        case .profileViewed:
            return localizedText(en: "Profile Activity", ar: "نشاط الملف الشخصي", ku: "چالاکیی پرۆفایل", language: language)
        case .verificationRequest:
            return localizedText(en: "Verification Request", ar: "طلب التحقق", ku: "داواکاری پشتڕاستکردنەوە", language: language)
        case .verificationApproved:
            return localizedText(en: "Verification Approved", ar: "تمت الموافقة على التحقق", ku: "پشتڕاستکردنەوە پەسەندکرا", language: language)
        case .verificationRejected:
            return localizedText(en: "Verification Update", ar: "تحديث التحقق", ku: "نوێکاری پشتڕاستکردنەوە", language: language)
        case .systemMessage:
            return "Souqira"
        default:
            return localizedText(en: "Notification", ar: "إشعار", ku: "ئاگادارکردنەوە", language: language)
        }
    }

    private func localizedText(en: String, ar: String, ku: String, language: String) -> String {
        switch language {
        case "ar":
            return ar
        case "ku":
            return ku
        default:
            return en
        }
    }

    private func localizedListingTitle(prefixEn: String, arTemplate: String, kuTemplate: String, title: String, language: String) -> String {
        switch language {
        case "ar":
            return arTemplate.replacingOccurrences(of: "%@", with: title)
        case "ku":
            return kuTemplate.replacingOccurrences(of: "%@", with: title)
        default:
            return "\(prefixEn): \(title)"
        }
    }
}
