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
    
    private let apiService = APIService()
    private let networkManager = NetworkManager.shared
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if networkManager.accessToken != nil {
            Task {
                await fetchCurrentUser()
            }
        }
    }
    
    func loginWithEmail(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.login(email: email, password: password)
            
            // Tokens are already stored in NetworkManager by APIService
            currentUser = response.user
            isAuthenticated = true
        } catch {
            errorMessage = "Failed to login. Please check your credentials."
            print("❌ Login error: \(error)")
        }
        
        isLoading = false
    }
    
    func registerWithEmail(name: String, email: String, password: String, phone: String, agreeToTerms: Bool) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.register(
                name: name,
                email: email,
                password: password,
                phone: phone,
                agreeToTerms: agreeToTerms
            )
            
            // Tokens are already stored in NetworkManager by APIService
            currentUser = response.user
            isAuthenticated = true
        } catch {
            errorMessage = "Failed to register. Please try again."
            print("❌ Registration error: \(error)")
        }
        
        isLoading = false
    }
    
    func loginWithWhatsApp(phone: String) async {
        isLoading = true
        errorMessage = nil
        
        // TODO: Implement WhatsApp OAuth flow
        errorMessage = "WhatsApp login coming soon"
        isLoading = false
    }
    
    func loginWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Sign in with Google and get ID token
            let idToken = try await GoogleSignInManager.shared.signIn()
            
            // Send ID token to backend
            let response = try await apiService.loginWithGoogle(idToken: idToken)
            
            // Tokens are already stored in NetworkManager by APIService
            currentUser = response.user
            isAuthenticated = true
            
        } catch {
            errorMessage = "Failed to sign in with Google. Please try again."
            print("❌ Google login error: \(error)")
        }
        
        isLoading = false
    }
    
    func fetchCurrentUser() async {
        do {
            currentUser = try await apiService.getCurrentUser()
            isAuthenticated = true
        } catch {
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
}
