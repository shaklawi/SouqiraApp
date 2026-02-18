//
//  PushNotificationManager.swift
//  Souqira
//
//  Created on 18/02/2026
//

import Foundation
import UserNotifications
import UIKit

class PushNotificationManager: NSObject {
    static let shared = PushNotificationManager()
    
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
        
        // TODO: Send device token to backend
        Task {
            await sendDeviceTokenToBackend(token)
        }
    }
    
    func handleRegistrationError(_ error: Error) {
        print("❌ Failed to register for remote notifications: \(error)")
    }
    
    private func sendDeviceTokenToBackend(_ token: String) async {
        // TODO: Implement API call to send token to backend
        // Example endpoint: POST /api/user/device-token
        print("📡 Would send device token to backend: \(token)")
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
        print("📬 Received notification while app in foreground: \(notification.request.content.body)")
        
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("📬 User tapped notification: \(userInfo)")
        
        // Handle notification action based on userInfo
        // TODO: Navigate to appropriate screen
        
        completionHandler()
    }
}
