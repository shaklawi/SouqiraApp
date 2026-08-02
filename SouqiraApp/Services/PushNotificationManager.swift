//
//  PushNotificationManager.swift
//  Souqira
//
//  Created on 18/02/2026
//

import Foundation
import UserNotifications
import UIKit

struct PushInboxItem: Codable, Identifiable {
    let id: String
    let title: String
    let body: String
    let receivedAt: Date
}

extension Notification.Name {
    static let pushInboxUpdated = Notification.Name("pushInboxUpdated")
}

class PushNotificationManager: NSObject {
    static let shared = PushNotificationManager()
    private let apiService = APIService()
    private let lastDeviceTokenKey = "souqira.lastDeviceToken"
    private let pushInboxStorageKey = "souqira.pushInboxItems"
    private let maxInboxItems = 40
    
    private override init() {
        super.init()
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Push notification permission granted: \(granted)")
            
            guard granted else {
                print("Push notification permission denied")
                return
            }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func handleDeviceToken(_ deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📱 Device Token: \(token)")
        UserDefaults.standard.set(token, forKey: lastDeviceTokenKey)
        
        Task {
            await syncDeviceToken(token)
        }
    }
    
    func handleRegistrationError(_ error: Error) {
        print("❌ Failed to register for remote notifications: \(error)")
    }
    
    func syncStoredDeviceToken() async {
        guard let token = UserDefaults.standard.string(forKey: lastDeviceTokenKey), !token.isEmpty else {
            return
        }

        await syncDeviceToken(token)
    }

    private func syncDeviceToken(_ token: String) async {
        do {
            try await apiService.registerPublicDeviceToken(token, platform: "ios")
            print("✅ Public device token uploaded")
        } catch {
            print("❌ Failed to upload public device token: \(error)")
        }

        guard NetworkManager.shared.accessToken != nil else {
            return
        }

        do {
            try await apiService.registerDeviceToken(token, platform: "ios")
            print("✅ Authenticated device token uploaded")
        } catch {
            print("❌ Failed to upload authenticated device token: \(error)")
        }
    }

    func getInboxItems() -> [PushInboxItem] {
        guard let data = UserDefaults.standard.data(forKey: pushInboxStorageKey) else {
            return []
        }

        do {
            return try JSONDecoder().decode([PushInboxItem].self, from: data)
        } catch {
            return []
        }
    }

    private func persistToInbox(title: String, body: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBody = body.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedBody.isEmpty else {
            return
        }

        var current = getInboxItems()
        current.insert(
            PushInboxItem(
                id: UUID().uuidString,
                title: trimmedTitle.isEmpty ? "Souqira" : trimmedTitle,
                body: trimmedBody,
                receivedAt: Date()
            ),
            at: 0
        )

        if current.count > maxInboxItems {
            current = Array(current.prefix(maxInboxItems))
        }

        if let encoded = try? JSONEncoder().encode(current) {
            UserDefaults.standard.set(encoded, forKey: pushInboxStorageKey)
            NotificationCenter.default.post(name: .pushInboxUpdated, object: nil)
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension PushNotificationManager: UNUserNotificationCenterDelegate {
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let content = notification.request.content
        print("📬 Received notification while app in foreground: \(content.body)")
        persistToInbox(title: content.title, body: content.body)
        
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let content = response.notification.request.content
        let userInfo = content.userInfo
        print("📬 User tapped notification: \(userInfo)")

        persistToInbox(title: content.title, body: content.body)
        
        completionHandler()
    }
}
