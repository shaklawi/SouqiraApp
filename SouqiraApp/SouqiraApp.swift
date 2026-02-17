//
//  SouqiraApp.swift
//  Souqira
//
//  Created on 17/02/2026
//

import SwiftUI

@main
struct SouqiraApp: App {
    @StateObject private var authViewModel = AuthenticationViewModel()
    @StateObject private var appSettings = AppSettings()
    
    init() {
        // Configure Google Sign In
        GoogleSignInManager.shared.configure()
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
        }
    }
}
