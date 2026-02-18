//
//  SettingsSheet.swift
//  Souqira
//
//  Created on 17/02/2026
//

import SwiftUI

struct SettingsSheet: View {
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showLanguageSelection = false
    
    var body: some View {
        NavigationStack {
            List {
                // Language Section - Always visible
                Section {
                    Button {
                        showLanguageSelection = true
                    } label: {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(LocalizationManager.language.get(language: appSettings.language))
                                    .foregroundColor(.primary)
                                Text(languageName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                } header: {
                    Text(LocalizationManager.settings.get(language: appSettings.language))
                }
                
                // Appearance
                Section {
                    Toggle(isOn: $appSettings.isDarkMode) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            Text(LocalizationManager.darkMode.get(language: appSettings.language))
                        }
                    }
                }
                
                // Account Section
                Section {
                    if authViewModel.isAuthenticated, let user = authViewModel.currentUser {
                        // Logged in - show profile and logout
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.name)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                        
                        NavigationLink {
                            ProfileView()
                        } label: {
                            HStack {
                                Image(systemName: "person.text.rectangle")
                                    .foregroundColor(.blue)
                                    .frame(width: 30)
                                Text(LocalizationManager.myListings.get(language: appSettings.language))
                            }
                        }
                        
                        Button(role: .destructive) {
                            authViewModel.logout()
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .frame(width: 30)
                                Text(LocalizationManager.logout.get(language: appSettings.language))
                            }
                        }
                    } else {
                        // Not logged in - show login button
                        NavigationLink {
                            AuthenticationView()
                        } label: {
                            HStack {
                                Image(systemName: "person.circle")
                                    .foregroundColor(.blue)
                                    .frame(width: 30)
                                Text(getLocalizedText(en: "Login / Sign Up", ar: "تسجيل الدخول / التسجيل", ku: "چوونەژوورەوە / تۆمارکردن"))
                            }
                        }
                    }
                } header: {
                    Text(getLocalizedText(en: "Account", ar: "الحساب", ku: "هەژمار"))
                }
                
                // About Section
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        Text(getLocalizedText(en: "Version", ar: "الإصدار", ku: "وەشان"))
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text(getLocalizedText(en: "About", ar: "حول", ku: "دەربارە"))
                }
            }
            .navigationTitle(LocalizationManager.settings.get(language: appSettings.language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizationManager.close.get(language: appSettings.language)) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showLanguageSelection) {
                LanguageSelectionSheet()
            }
        }
    }
    
    private var languageName: String {
        switch appSettings.language {
        case "ar":
            return "العربية"
        case "ku":
            return "کوردی"
        default:
            return "English"
        }
    }
    
    private func getLocalizedText(en: String, ar: String, ku: String) -> String {
        switch appSettings.language {
        case "ar":
            return ar
        case "ku":
            return ku
        default:
            return en
        }
    }
}

struct LanguageSelectionSheet: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss
    
    let languages = [
        ("en", "English", "🇬🇧"),
        ("ar", "العربية", "🇮🇶"),
        ("ku", "کوردی", "🟥⚪🟩")
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(languages, id: \.0) { code, name, flag in
                    Button {
                        appSettings.setLanguage(code)
                        dismiss()
                    } label: {
                        HStack {
                            Text(flag)
                                .font(.title2)
                            Text(name)
                                .foregroundColor(.primary)
                            Spacer()
                            if appSettings.language == code {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle(LocalizationManager.selectLanguage.get(language: appSettings.language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizationManager.done.get(language: appSettings.language)) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsSheet()
        .environmentObject(AppSettings())
        .environmentObject(AuthenticationViewModel())
}
