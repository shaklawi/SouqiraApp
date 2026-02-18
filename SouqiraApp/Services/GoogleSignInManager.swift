//
//  GoogleSignInManager.swift
//  Souqira
//
//  Created on 18/02/2026
//

import Foundation
#if canImport(GoogleSignIn)
import GoogleSignIn
#endif
import UIKit

@MainActor
class GoogleSignInManager: ObservableObject {
    static let shared = GoogleSignInManager()
    
    @Published var isSignedIn = false
    @Published var errorMessage: String?
    
    private init() {}
    
    /// Configure Google Sign In with the client ID from Info.plist
    func configure() {
        #if canImport(GoogleSignIn)
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else {
            print("⚠️ Warning: GIDClientID not found in Info.plist")
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        #else
        print("⚠️ GoogleSignIn framework not available")
        #endif
    }
    
    /// Sign in with Google
    func signIn() async throws -> String {
        #if canImport(GoogleSignIn)
        // Get the presenting view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw GoogleSignInError.noViewController
        }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            // Get the ID token
            guard let idToken = result.user.idToken?.tokenString else {
                throw GoogleSignInError.noIDToken
            }
            
            isSignedIn = true
            return idToken
            
        } catch {
            print("❌ Google Sign In error: \(error)")
            throw error
        }
        #else
        throw GoogleSignInError.notAvailable
        #endif
    }
    
    /// Sign out from Google
    func signOut() {
        #if canImport(GoogleSignIn)
        GIDSignIn.sharedInstance.signOut()
        isSignedIn = false
        #endif
    }
    
    /// Restore previous sign in
    func restorePreviousSignIn() async throws -> String? {
        #if canImport(GoogleSignIn)
        do {
            let user = try await GIDSignIn.sharedInstance.restorePreviousSignIn()
            guard let idToken = user.idToken?.tokenString else {
                throw GoogleSignInError.noIDToken
            }
            isSignedIn = true
            return idToken
        } catch {
            print("ℹ️ No previous Google sign in to restore")
            return nil
        }
        #else
        return nil
        #endif
    }
    
    /// Handle URL callback from Google Sign In
    func handleURL(_ url: URL) -> Bool {
        #if canImport(GoogleSignIn)
        return GIDSignIn.sharedInstance.handle(url)
        #else
        return false
        #endif
    }
}

// MARK: - Error Types
enum GoogleSignInError: LocalizedError {
    case noViewController
    case noIDToken
    case notAvailable
    
    var errorDescription: String? {
        switch self {
        case .noViewController:
            return "Unable to present Google Sign In"
        case .noIDToken:
            return "Failed to get ID token from Google"
        case .notAvailable:
            return "Google Sign In is not available"
        }
    }
}
