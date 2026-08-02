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
    @State private var showTerms = false
    @State private var showPrivacy = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                SouqiraPatternBackground()

                ScrollView {
                    VStack(spacing: 18) {
                        settingsCard
                        accountCard
                        aboutCard
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
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
            .sheet(isPresented: $showTerms) {
                TermsView()
            }
            .sheet(isPresented: $showPrivacy) {
                PrivacyPolicyView()
            }
        }
    }

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                showLanguageSelection = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "globe")
                        .font(.title3)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .frame(width: 34)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(LocalizationManager.language.get(language: appSettings.language))
                            .foregroundColor(DesignSystem.Colors.gray900)
                        Text(languageName)
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.gray500)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.gray400)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.92))
                )
            }
            .buttonStyle(.plain)

            Toggle(isOn: $appSettings.isDarkMode) {
                HStack(spacing: 12) {
                    Image(systemName: "moon.fill")
                        .font(.title3)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .frame(width: 34)
                    Text(LocalizationManager.darkMode.get(language: appSettings.language))
                        .foregroundColor(DesignSystem.Colors.gray900)
                }
            }
            .tint(DesignSystem.Colors.primary)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(0.92))
            )
        }
        .padding(16)
        .background(cardBackground)
    }

    private var accountCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(getLocalizedText(en: "Account", ar: "الحساب", ku: "هەژمار"))
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.gray700)

            if authViewModel.isAuthenticated, let user = authViewModel.currentUser {
                HStack(spacing: 12) {
                    Circle()
                        .fill(DesignSystem.Colors.primaryGradient)
                        .frame(width: 42, height: 42)
                        .overlay {
                            Text(user.name.prefix(1).uppercased())
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.name)
                            .font(.headline)
                            .foregroundColor(DesignSystem.Colors.gray900)
                        Text(user.email)
                            .font(.caption)
                            .foregroundColor(DesignSystem.Colors.gray500)
                    }

                    Spacer()
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.92))
                )

                NavigationLink {
                    ProfileView()
                } label: {
                    settingsRow(
                        icon: "person.text.rectangle",
                        title: LocalizationManager.myListings.get(language: appSettings.language),
                        trailing: nil,
                        destructive: false,
                        showChevron: true
                    )
                }
                .buttonStyle(.plain)

                Button(role: .destructive) {
                    authViewModel.logout()
                    dismiss()
                } label: {
                    settingsRow(
                        icon: "rectangle.portrait.and.arrow.right",
                        title: LocalizationManager.logout.get(language: appSettings.language),
                        trailing: nil,
                        destructive: true,
                        showChevron: false
                    )
                }
            } else {
                NavigationLink {
                    AuthenticationView()
                } label: {
                    settingsRow(
                        icon: "person.circle",
                        title: getLocalizedText(en: "Login / Sign Up", ar: "تسجيل الدخول / التسجيل", ku: "چوونەژوورەوە / تۆمارکردن"),
                        trailing: nil,
                        destructive: false,
                        showChevron: true
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(getLocalizedText(en: "About", ar: "حول", ku: "دەربارە"))
                .font(.headline)
                .foregroundColor(DesignSystem.Colors.gray700)

            settingsRow(
                icon: "info.circle",
                title: getLocalizedText(en: "Version", ar: "الإصدار", ku: "وەشان"),
                trailing: "1.0.0",
                destructive: false,
                showChevron: false
            )

            Button {
                showTerms = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "doc.text")
                        .font(.title3)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .frame(width: 34)
                    Text(getLocalizedText(en: "Terms & Conditions", ar: "الشروط والأحكام", ku: "مەرج و مادەکان"))
                        .foregroundColor(DesignSystem.Colors.gray900)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.gray400)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.92))
                )
            }
            .buttonStyle(.plain)

            Button {
                showPrivacy = true
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "hand.raised")
                        .font(.title3)
                        .foregroundColor(DesignSystem.Colors.primary)
                        .frame(width: 34)
                    Text(getLocalizedText(en: "Privacy Policy", ar: "سياسة الخصوصية", ku: "سیاسەتی نهێنی"))
                        .foregroundColor(DesignSystem.Colors.gray900)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.gray400)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.92))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(cardBackground)
    }

    private func settingsRow(
        icon: String,
        title: String,
        trailing: String?,
        destructive: Bool,
        showChevron: Bool
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(destructive ? .red : DesignSystem.Colors.primary)
                .frame(width: 34)

            Text(title)
                .foregroundColor(destructive ? .red : DesignSystem.Colors.gray900)

            Spacer()

            if let trailing {
                Text(trailing)
                    .foregroundColor(DesignSystem.Colors.gray500)
            }

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(DesignSystem.Colors.gray400)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.92))
        )
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(DesignSystem.Colors.gray200.opacity(0.9), lineWidth: 1)
            )
            .shadow(color: DesignSystem.Colors.gray900.opacity(0.06), radius: 12, x: 0, y: 4)
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

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    sectionHeader("Privacy Policy")
                    bodyText("Souqira collects only the information needed to provide marketplace features such as account authentication, listing management, and messaging.")

                    sectionHeader("What We Collect")
                    bodyText("We may collect your name, email, phone number, profile details, listing content, and app usage signals needed to operate and secure the service.")

                    sectionHeader("How We Use Data")
                    bodyText("We use your data to create and manage your account, enable communications, show listings, prevent abuse, and improve app performance.")

                    sectionHeader("Content Moderation")
                    bodyText("Reports and moderation actions are processed to keep the platform safe. Violating content may be removed and accounts may be limited.")

                    sectionHeader("Data Sharing")
                    bodyText("We do not sell personal data. Data may be shared with trusted infrastructure providers strictly to deliver core app features.")

                    sectionHeader("Your Controls")
                    bodyText("You can update profile details, block users, and request account deletion from within the app settings.")

                    sectionHeader("Contact")
                    bodyText("For privacy requests, contact support@souqira.com.")
                }
                .padding(20)
            }
            .navigationTitle("Privacy Policy")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundColor(.primary)
    }

    private func bodyText(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .foregroundColor(.secondary)
            .lineSpacing(4)
    }
}

struct LanguageSelectionSheet: View {
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss
    
    let languages = [
        ("en", "English", "🇬🇧"),
        ("ar", "العربية", "🇮🇶"),
        ("ku", "کوردی", "")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                SouqiraPatternBackground()

                VStack(spacing: 10) {
                    ForEach(languages, id: \.0) { code, name, flag in
                        Button {
                            appSettings.setLanguage(code)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                flagView(code: code, emoji: flag)

                                Text(name)
                                    .foregroundColor(DesignSystem.Colors.gray900)

                                Spacer()

                                if appSettings.language == code {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(DesignSystem.Colors.primary)
                                }
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.white.opacity(0.92))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(14)
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
    
    private func flagView(code: String, emoji: String) -> some View {
        Group {
            if code == "ku" {
                Image("flag")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 28, height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 0.5)
                    )
            } else {
                Text(emoji)
                    .font(.title2)
            }
        }
        .frame(width: 28, alignment: .leading)
    }
}

#Preview {
    SettingsSheet()
        .environmentObject(AppSettings())
        .environmentObject(AuthenticationViewModel())
}
