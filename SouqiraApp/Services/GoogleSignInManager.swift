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
    
    /// Configure Google Sign In with client IDs from Info.plist.
    /// By default we use only the iOS client ID because many backends verify tokens against it.
    func configure(useServerClientID: Bool = false) {
        #if canImport(GoogleSignIn)
        print("🔧 [GoogleSignInManager] Configuring Google Sign In...")
        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String else {
            print("⚠️ [GoogleSignInManager] GIDClientID not found in Info.plist")
            return
        }

        print("✅ [GoogleSignInManager] Found Client ID: \(clientID)")

        let serverClientID = Bundle.main.object(forInfoDictionaryKey: "GIDServerClientID") as? String

        let config: GIDConfiguration
        if useServerClientID,
           let serverClientID = serverClientID,
           !serverClientID.isEmpty,
           !serverClientID.contains("REPLACE_WITH") {
            print("✅ [GoogleSignInManager] serverClientID: \(serverClientID)")
            config = GIDConfiguration(clientID: clientID, serverClientID: serverClientID)
        } else {
            if useServerClientID {
                print("⚠️ [GoogleSignInManager] serverClientID requested but missing/invalid; falling back to iOS client ID")
            }
            print("✅ [GoogleSignInManager] Using iOS client ID audience")
            config = GIDConfiguration(clientID: clientID)
        }

        GIDSignIn.sharedInstance.configuration = config
        print("✅ [GoogleSignInManager] Configuration complete")
        #else
        print("⚠️ [GoogleSignInManager] GoogleSignIn framework not available")
        #endif
    }
    
    /// Sign in with Google — returns the ID token to send to the backend.
    func signIn() async throws -> String {
        #if canImport(GoogleSignIn)
        print("📱 [GoogleSignInManager] Starting sign in flow...")

        // Always sign out first to clear any cached tokens from previous configurations
        GIDSignIn.sharedInstance.signOut()
        print("🔄 [GoogleSignInManager] Cleared previous sign-in session")

        // Reconfigure to ensure latest plist values are used.
        // Default to iOS client ID audience for backend compatibility.
        configure(useServerClientID: false)

        guard let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String,
              !clientID.isEmpty else {
            print("❌ [GoogleSignInManager] GIDClientID missing in Info.plist")
            throw GoogleSignInError.invalidClientID
        }

        // Get the presenting view controller
        let windowScene = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first ?? UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first

        guard let scene = windowScene else {
            print("❌ [GoogleSignInManager] No window scene found")
            throw GoogleSignInError.noViewController
        }

        let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first

        guard var rootViewController = window?.rootViewController else {
            print("❌ [GoogleSignInManager] No root view controller found")
            throw GoogleSignInError.noViewController
        }

        while let presented = rootViewController.presentedViewController {
            rootViewController = presented
        }

        print("✅ [GoogleSignInManager] Found view controller: \(type(of: rootViewController))")

        do {
            print("🔄 [GoogleSignInManager] Calling GIDSignIn.signIn...")
            
            // Log current configuration
            if let config = GIDSignIn.sharedInstance.configuration {
                print("🔍 [GoogleSignInManager] Config clientID: \(config.clientID)")
                print("🔍 [GoogleSignInManager] Config serverClientID: \(config.serverClientID ?? "nil")")
            }
            
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            print("✅ [GoogleSignInManager] Sign in successful!")
            print("✅ [GoogleSignInManager] User email: \(result.user.profile?.email ?? "unknown")")

            // Log server auth code if available
            if let serverAuthCode = result.serverAuthCode {
                print("🔍 [GoogleSignInManager] Got serverAuthCode: \(serverAuthCode.prefix(30))...")
            } else {
                print("⚠️ [GoogleSignInManager] No serverAuthCode returned")
            }

            // Get the ID token
            guard let idToken = result.user.idToken?.tokenString else {
                print("❌ [GoogleSignInManager] No ID token in result")
                throw GoogleSignInError.noIDToken
            }

            print("✅ [GoogleSignInManager] Got ID token (length: \(idToken.count))")
            debugLogToken(idToken)
            
            // Check if the token audience matches the serverClientID
            let serverClientID = Bundle.main.object(forInfoDictionaryKey: "GIDServerClientID") as? String
            let tokenAud = getTokenAudience(idToken)
            
            if let serverClientID = serverClientID, let aud = tokenAud {
                if aud == serverClientID {
                    print("✅ [GoogleSignInManager] Token audience matches serverClientID ✓")
                } else {
                    print("⚠️ [GoogleSignInManager] Token audience (\(aud)) does NOT match serverClientID (\(serverClientID))")
                    print("⚠️ [GoogleSignInManager] This may cause backend rejection")
                }
            }

            isSignedIn = true
            return idToken

        } catch let error as GoogleSignInError {
            throw error
        } catch let error as NSError {
            print("❌ [GoogleSignInManager] Sign in failed: \(error.localizedDescription)")
            if error.localizedDescription.lowercased().contains("deleted") ||
               error.localizedDescription.lowercased().contains("client") {
                throw GoogleSignInError.invalidClientID
            }
            throw error
        }
        #else
        print("❌ [GoogleSignInManager] GoogleSignIn not available")
        throw GoogleSignInError.notAvailable
        #endif
    }

    // MARK: - Debug Helpers

    private func getTokenAudience(_ token: String) -> String? {
        let parts = token.split(separator: ".")
        guard parts.count >= 2 else { return nil }
        var base64 = String(parts[1])
        let remainder = base64.count % 4
        if remainder > 0 { base64 += String(repeating: "=", count: 4 - remainder) }
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json["aud"] as? String
    }

    private func debugLogToken(_ token: String) {
        let parts = token.split(separator: ".")
        guard parts.count >= 2 else { return }
        var base64 = String(parts[1])
        let remainder = base64.count % 4
        if remainder > 0 { base64 += String(repeating: "=", count: 4 - remainder) }
        if let data = Data(base64Encoded: base64),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            print("🔍 [GoogleSignInManager] Token aud: \(json["aud"] ?? "unknown")")
            print("🔍 [GoogleSignInManager] Token iss: \(json["iss"] ?? "unknown")")
            print("🔍 [GoogleSignInManager] Token sub: \(json["sub"] ?? "unknown")")
            let exp = json["exp"] as? TimeInterval ?? 0
            print("🔍 [GoogleSignInManager] Token exp: \(Date(timeIntervalSince1970: exp))")
        }
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
    case invalidClientID

    var errorDescription: String? {
        switch self {
        case .noViewController:
            return "Unable to present Google Sign In"
        case .noIDToken:
            return "Failed to get ID token from Google"
        case .notAvailable:
            return "Google Sign In is not available"
        case .invalidClientID:
            return "Google Sign In is not configured correctly. Please check GIDClientID in Info.plist."
        }
    }
}
