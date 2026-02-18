//
//  AuthenticationView.swift
//  Souqira
//
//  Created on 17/02/2026
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @State private var phoneNumber = ""
    @State private var showWhatsAppLogin = false
    @State private var showErrorAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Logo and Title
                VStack(spacing: 16) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Welcome to Souqira")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Create an account to post ads")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Sign in options
                VStack(spacing: 16) {
                    // WhatsApp Sign In
                    Button(action: {
                        showWhatsAppLogin = true
                    }) {
                        HStack {
                            Image(systemName: "message.fill")
                                .font(.title3)
                            Text("Sign in with WhatsApp")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    // Google Sign In
                    Button(action: {
                        print("🔵 Google Sign In button tapped")
                        Task {
                            await authViewModel.loginWithGoogle()
                            if authViewModel.isAuthenticated {
                                print("✅ Google Sign In successful, dismissing")
                                dismiss()
                            } else if let error = authViewModel.errorMessage {
                                print("❌ Google Sign In failed: \(error)")
                                showErrorAlert = true
                            }
                        }
                    }) {
                        HStack {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .tint(.black)
                            } else {
                                Image(systemName: "g.circle.fill")
                                    .font(.title3)
                            }
                            Text("Sign in with Google")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .disabled(authViewModel.isLoading)
                }
                .padding(.horizontal)
                
                // Terms
                Text("By signing up you agree to [Terms and conditions](https://souqira.com/terms-and-conditions)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showWhatsAppLogin) {
                WhatsAppLoginView()
            }
            .alert("Sign In Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {
                    authViewModel.errorMessage = nil
                }
            } message: {
                Text(authViewModel.errorMessage ?? "An error occurred")
            }
        }
    }
}

struct WhatsAppLoginView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @State private var phoneNumber = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "message.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .padding(.top, 40)
                
                Text("Sign in with WhatsApp")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Enter your WhatsApp number to continue")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Phone Number")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        Text("🇮🇶 +964")
                            .foregroundColor(.secondary)
                        
                        TextField("750 123 4567", text: $phoneNumber)
                            .keyboardType(.phonePad)
                            .textContentType(.telephoneNumber)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                Button(action: {
                    Task {
                        await authViewModel.loginWithWhatsApp(phone: "+964\(phoneNumber)")
                        if authViewModel.isAuthenticated {
                            dismiss()
                        }
                    }
                }) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        Text("Continue")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(phoneNumber.isEmpty ? Color.gray : Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .disabled(phoneNumber.isEmpty || authViewModel.isLoading)
                
                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationViewModel())
}
