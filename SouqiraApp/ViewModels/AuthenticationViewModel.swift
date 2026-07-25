//
//  AuthenticationViewModel.swift
//  Souqira
//
//  Created on 17/02/2026
//

import Foundation
import SwiftUI

@MainActor
class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private let apiService = APIService()
    private let networkManager = NetworkManager.shared
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if networkManager.accessToken != nil {
            isAuthenticated = true

            Task {
                await fetchCurrentUser()
            }
        }
    }
    
    func loginWithEmail(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let response = try await apiService.login(email: email, password: password)
            
            // Tokens are already stored in NetworkManager by APIService
            currentUser = response.user
            isAuthenticated = true
        } catch let networkError as NetworkError {
            switch networkError {
            case .serverError(let message):
                errorMessage = message
            case .unauthorized:
                errorMessage = "Failed to login. Please check your credentials."
            default:
                errorMessage = "Failed to login. Please try again."
            }
            print("❌ Login error: \(networkError)")
        } catch {
            errorMessage = "Failed to login. Please try again."
            print("❌ Login error: \(error)")
        }
        
        isLoading = false
    }
    
    func registerWithEmail(name: String, email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            let message = try await apiService.register(name: name, email: email, password: password)
            successMessage = message
        } catch let networkError as NetworkError {
            switch networkError {
            case .serverError(let message):
                errorMessage = message
            default:
                errorMessage = "Failed to register. Please try again."
            }
            print("❌ Registration error: \(networkError)")
        } catch {
            errorMessage = "Failed to register. Please try again."
            print("❌ Registration error: \(error)")
        }
        
        isLoading = false
    }

    func resendVerificationEmail(email: String) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let message = try await apiService.resendVerificationEmail(email: email)
            successMessage = message
        } catch let networkError as NetworkError {
            switch networkError {
            case .serverError(let message):
                if message.localizedCaseInsensitiveContains("/api/auth/resend-verification not found") {
                    errorMessage = "Server update pending. Verification resend not available yet."
                } else {
                    errorMessage = message
                }
            default:
                errorMessage = "Failed to resend verification email. Please try again."
            }
            print("❌ Resend verification error: \(networkError)")
        } catch {
            errorMessage = "Failed to resend verification email. Please try again."
            print("❌ Resend verification error: \(error)")
        }

        isLoading = false
    }

    func sendForgotPasswordCode(email: String) async {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        do {
            let message = try await apiService.forgotPassword(email: email)
            successMessage = message
        } catch let networkError as NetworkError {
            switch networkError {
            case .serverError(let message):
                errorMessage = message
            default:
                errorMessage = "Failed to send reset code. Please try again."
            }
        } catch {
            errorMessage = "Failed to send reset code. Please try again."
        }

        isLoading = false
    }

    func confirmResetCode(email: String, code: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        defer { isLoading = false }

        do {
            let message = try await apiService.confirmResetCode(email: email, code: code)
            successMessage = message
            return true
        } catch let networkError as NetworkError {
            switch networkError {
            case .serverError(let message):
                errorMessage = message
            default:
                errorMessage = "Invalid or expired code."
            }
            return false
        } catch {
            errorMessage = "Invalid or expired code."
            return false
        }
    }

    func resetPassword(email: String, newPassword: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        defer { isLoading = false }

        do {
            let message = try await apiService.resetPassword(email: email, newPassword: newPassword)
            successMessage = message
            return true
        } catch let networkError as NetworkError {
            switch networkError {
            case .serverError(let message):
                errorMessage = message
            default:
                errorMessage = "Failed to reset password."
            }
            return false
        } catch {
            errorMessage = "Failed to reset password."
            return false
        }
    }
    
    func loginWithWhatsApp(phone: String) async {
        isLoading = true
        errorMessage = nil
        
        // TODO: Implement WhatsApp OAuth flow
        errorMessage = "WhatsApp login coming soon"
        isLoading = false
    }
    
    func loginWithGoogle() async {
        print("🔵 [AuthViewModel] Starting Google Sign In")
        isLoading = true
        errorMessage = nil
        
        // Check if running on simulator
        #if targetEnvironment(simulator)
        let isSimulator = true
        #else
        let isSimulator = false
        #endif
        
        do {
            let idToken: String
            
            if isSimulator {
                // In simulator, use a test token for development/debugging
                print("⚠️ [AuthViewModel] Running on Simulator - using TEST mode")
                print("📌 To test with real Google token, deploy to physical iPhone")
                
                // For actual testing, you would get real token from Google SDK
                // But for now in simulator, we can't validate real tokens on backend
                print("📱 [AuthViewModel] Calling GoogleSignInManager.signIn()...")
                idToken = try await GoogleSignInManager.shared.signIn()
                print("✅ [AuthViewModel] Got ID token from Google SDK: \(idToken.prefix(20))...")
            } else {
                // On real device
                print("📱 [AuthViewModel] Calling GoogleSignInManager.signIn()...")
                idToken = try await GoogleSignInManager.shared.signIn()
                print("✅ [AuthViewModel] Got ID token from Google: \(idToken.prefix(20))...")
            }
            
            print("📡 [AuthViewModel] Sending ID token to backend: POST /api/auth/google/token")
            print("📡 [AuthViewModel] Token length: \(idToken.count) characters")
            
            // Send ID token to backend
            let response = try await apiService.loginWithGoogle(idToken: idToken)
            print("✅ [AuthViewModel] Backend login successful")
            print("✅ [AuthViewModel] User: \(response.user.email)")
            print("✅ [AuthViewModel] Access token: \(response.accessToken.prefix(20))...")
            
            // Tokens are already stored in NetworkManager by APIService
            currentUser = response.user
            isAuthenticated = true
            print("✅ [AuthViewModel] User authenticated: \(response.user.name)")
            
        } catch let error as GoogleSignInError {
            switch error {
            case .noViewController:
                errorMessage = "Could not present Google Sign In. Please try again."
            case .noIDToken:
                errorMessage = "Failed to get authentication token from Google."
            case .notAvailable:
                errorMessage = "Google Sign In is not available. Please check your configuration."
            case .invalidClientID:
                errorMessage = "Google Sign In is not configured correctly. Please check your configuration."
            }
            print("❌ [AuthViewModel] Google Sign In SDK error: \(error)")
        } catch let error as NetworkError {
            print("❌ [AuthViewModel] Network error type: \(error)")
            
            // Check if this is a simulator token validation error
            #if targetEnvironment(simulator)
            if case .serverError(let message) = error, message.contains("Invalid Google token") {
                errorMessage = "ℹ️ Simulator Limitation:\n\nGoogle Sign In tokens generated in the simulator cannot be validated by the backend (they're test tokens).\n\nTo fully test Google Auth:\n\n1. Deploy to a physical iPhone\n2. Or contact backend team about test token support"
                print("⚠️ [AuthViewModel] Simulator token limitation - backend cannot validate simulator tokens")
            } else {
                errorMessage = networkErrorMessage(error)
            }
            #else
            if case .serverError(let message) = error,
               message.localizedCaseInsensitiveContains("invalid google token") {
                errorMessage = "Google token blev afvist af backend. Vi sender nu iOS client-ID tokenformat, men backend skal matche samme Google client config. Prøv igen, og hvis fejlen fortsætter skal backend-teamet verificere Google audience/client ID."
            } else {
                errorMessage = networkErrorMessage(error)
            }
            #endif
            
            print("❌ [AuthViewModel] Error message: \(errorMessage ?? "unknown")")
        } catch {
            print("❌ [AuthViewModel] Unexpected error: \(error)")
            print("❌ [AuthViewModel] Error type: \(type(of: error))")
            errorMessage = "Failed to sign in with Google. Please try again."
        }
        
        isLoading = false
    }

    func loginWithApple(idToken: String, userIdentifier: String, email: String?, fullName: PersonNameComponents?) async {
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiService.loginWithApple(
                idToken: idToken,
                userIdentifier: userIdentifier,
                email: email,
                fullName: fullName
            )
            currentUser = response.user
            isAuthenticated = true
        } catch let error as NetworkError {
            errorMessage = networkErrorMessage(error)
            print("❌ [AuthViewModel] Apple Sign In network error: \(error)")
        } catch {
            errorMessage = "Failed to sign in with Apple. Please try again."
            print("❌ [AuthViewModel] Apple Sign In unexpected error: \(error)")
        }

        isLoading = false
    }
    
    func fetchCurrentUser() async {
        do {
            currentUser = try await apiService.getCurrentUser()
            isAuthenticated = true
        } catch let error as NetworkError {
            if case .unauthorized = error {
                logout()
                return
            }

            errorMessage = networkErrorMessage(error)
        } catch {
            errorMessage = "Failed to restore your session. Please try again."
            print("❌ [AuthViewModel] Restore session failed: \(error)")
            if networkManager.accessToken == nil {
                logout()
            }
        }

        if networkManager.accessToken == nil {
            logout()
        }
    }
    
    func logout() {
        networkManager.clearAuthToken()
        currentUser = nil
        isAuthenticated = false
        
        Task {
            try? await apiService.logout()
        }
    }
    
    func deleteAccount() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await apiService.deleteAccount()
            // Clear local state
            networkManager.clearAuthToken()
            currentUser = nil
            isAuthenticated = false
            successMessage = "Account deleted successfully"
        } catch {
            errorMessage = "Failed to delete account. Please try again."
            print("❌ [AuthViewModel] Delete account failed: \(error)")
        }
        
        isLoading = false
    }
    
    private func networkErrorMessage(_ error: NetworkError) -> String {
        switch error {
        case .serverError(let message):
            return message
        case .unauthorized:
            return "Unauthorized. Please try again."
        case .invalidURL:
            return "Invalid server URL. Please try again later."
        case .invalidResponse:
            return "Invalid server response. Please try again."
        case .decodingError:
            return "Unexpected server response. Please try again."
        case .noData:
            return "No data received from server. Please try again."
        case .httpError(let status):
            return "Server error (\(status)). Please try again."
        case .requestFailed(let underlying):
            return underlying.localizedDescription
        }
    }
}
