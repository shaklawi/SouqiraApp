//
//  SouqiraApp.swift
//  Souqira
//
//  Created on 17/02/2026
//

import SwiftUI
import UserNotifications

@main
struct SouqiraApp: App {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @StateObject private var appSettings = AppSettings()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Configure Google Sign In
        GoogleSignInManager.shared.configure()
        
        // Setup push notification delegate
        // TODO: Uncomment when PushNotificationManager is added to build
        // UNUserNotificationCenter.current().delegate = PushNotificationManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(appSettings)
                .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
                .onOpenURL { url in
                    // Handle Google Sign In callback
                    _ = GoogleSignInManager.shared.handleURL(url)
                }
                .onAppear {
                    // Register for push notifications when app appears
                    // TODO: Uncomment when PushNotificationManager is added to build
                    // PushNotificationManager.shared.registerForPushNotifications()
                }
        }
    }
}

// MARK: - AppDelegate for Push Notifications
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // TODO: Uncomment when PushNotificationManager is added to build
        // PushNotificationManager.shared.handleDeviceToken(deviceToken)
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("📱 Device Token: \(token)")
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        // TODO: Uncomment when PushNotificationManager is added to build
        // PushNotificationManager.shared.handleRegistrationError(error)
        print("❌ Failed to register for remote notifications: \(error)")
    }
}
