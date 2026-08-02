//
//  SouqiraApp.swift
//  Souqira
//
//  Created on 17/02/2026
//

import SwiftUI
import UserNotifications
#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

@main
struct SouqiraApp: App {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @StateObject private var appSettings = AppSettings()
    @StateObject private var localizationManager = LocalizationManager.shared
    @StateObject private var appNotificationManager = AppNotificationManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Configure Google Sign In
        GoogleSignInManager.shared.configure()
        
        // Setup push notification delegate
        UNUserNotificationCenter.current().delegate = PushNotificationManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(appSettings)
                .environmentObject(localizationManager)
                .environmentObject(appNotificationManager)
                .preferredColorScheme(appSettings.isDarkMode ? .dark : .light)
                .onOpenURL { url in
                    // Handle Google Sign In callback
                    _ = GoogleSignInManager.shared.handleURL(url)
                }
                .onAppear {
                    localizationManager.language = appSettings.language
                    PushNotificationManager.shared.registerForPushNotifications()
                    Task {
                        await PushNotificationManager.shared.syncStoredDeviceToken()
                    }
                }
                .onChange(of: appSettings.language) { newLanguage in
                    localizationManager.language = newLanguage
                }
                .task(id: authViewModel.isAuthenticated) {
                    await PushNotificationManager.shared.syncStoredDeviceToken()

                    if authViewModel.isAuthenticated {
                        await appNotificationManager.pollingLoop()
                    } else {
                        appNotificationManager.reset()
                    }
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
        PushNotificationManager.shared.handleDeviceToken(deviceToken)
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        PushNotificationManager.shared.handleRegistrationError(error)
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        #if canImport(GoogleSignIn)
        return GIDSignIn.sharedInstance.handle(url)
        #else
        return false
        #endif
    }
}
