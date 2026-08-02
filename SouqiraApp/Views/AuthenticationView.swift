//
//  AuthenticationView.swift
//  Souqira
//
//  Created on 17/02/2026
//

import SwiftUI
import AuthenticationServices

private func authLocalizedText(language: String, en: String, ar: String, ku: String) -> String {
    switch language {
    case "ar":
        return ar
    case "ku":
        return ku
    default:
        return en
    }
}

private func authIsRTL(_ language: String) -> Bool {
    language == "ar" || language == "ku"
}

struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss
    @State private var phoneNumber = ""
    @State private var showWhatsAppLogin = false
    @State private var showEmailLogin = false
    @State private var showTerms = false
    @State private var showErrorAlert = false
    @AppStorage("hasAcceptedTerms") private var hasAcceptedTerms = false

    private var isRTL: Bool { authIsRTL(appSettings.language) }

    private func localizedText(en: String, ar: String, ku: String) -> String {
        authLocalizedText(language: appSettings.language, en: en, ar: ar, ku: ku)
    }
    
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
                    
                    Text(localizedText(
                        en: "Welcome to Souqira",
                        ar: "مرحبًا بك في سوقيرة",
                        ku: "بەخێربێیت بۆ سووقێرا"
                    ))
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(localizedText(
                        en: "Create an account to post ads",
                        ar: "أنشئ حسابًا لنشر الإعلانات",
                        ku: "هەژمارێک دروست بکە بۆ بڵاوکردنەوەی ڕیکلام"
                    ))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Sign in options
                VStack(spacing: 16) {
                    // Terms acceptance — only shown until the user has accepted once
                    if !hasAcceptedTerms {
                        Button(action: { hasAcceptedTerms = true }) {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "square")
                                    .foregroundColor(.gray)
                                    .font(.title3)
                                HStack(spacing: 4) {
                                    Text(localizedText(
                                        en: "I agree to the",
                                        ar: "أوافق على",
                                        ku: "ڕازیم بە"
                                    ))
                                        .font(.footnote)
                                        .foregroundColor(.primary)
                                    Button(localizedText(
                                        en: "Terms and Conditions",
                                        ar: "الشروط والأحكام",
                                        ku: "مەرج و مادەکان"
                                    )) { showTerms = true }
                                        .font(.footnote)
                                        .foregroundColor(.blue)
                                }
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    // Email Sign In (for reviewer/demo access)
                    Button(action: {
                        showEmailLogin = true
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .font(.title3)
                            Text(localizedText(
                                en: "Sign in with Email",
                                ar: "تسجيل الدخول بالبريد الإلكتروني",
                                ku: "چوونەژوورەوە بە ئیمەیڵ"
                            ))
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }

                    SignInWithAppleButton(.signIn, onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    }, onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                                authViewModel.errorMessage = localizedText(
                                    en: "Failed to read Apple credentials.",
                                    ar: "تعذر قراءة بيانات اعتماد Apple.",
                                    ku: "نەکرا زانیارییەکانی Apple بخوێندرێنەوە."
                                )
                                showErrorAlert = true
                                return
                            }

                            guard let tokenData = credential.identityToken,
                                  let idToken = String(data: tokenData, encoding: .utf8) else {
                                authViewModel.errorMessage = localizedText(
                                    en: "Failed to get Apple identity token.",
                                    ar: "تعذر الحصول على رمز هوية Apple.",
                                    ku: "نەکرا تۆکنی ناسنامەی Apple وەربگیرێت."
                                )
                                showErrorAlert = true
                                return
                            }

                            Task {
                                await authViewModel.loginWithApple(
                                    idToken: idToken,
                                    userIdentifier: credential.user,
                                    email: credential.email,
                                    fullName: credential.fullName
                                )

                                if authViewModel.isAuthenticated {
                                    dismiss()
                                } else if authViewModel.errorMessage != nil {
                                    showErrorAlert = true
                                }
                            }

                        case .failure(let error):
                            authViewModel.errorMessage = error.localizedDescription
                            showErrorAlert = true
                        }
                    })
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 52)
                    .cornerRadius(12)

                    // WhatsApp Sign In
                    Button(action: {
                        showWhatsAppLogin = true
                    }) {
                        HStack {
                            Image(systemName: "message.fill")
                                .font(.title3)
                            Text(localizedText(
                                en: "Sign in with WhatsApp",
                                ar: "تسجيل الدخول عبر واتساب",
                                ku: "چوونەژوورەوە بە واتساپ"
                            ))
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
                            Text(localizedText(
                                en: "Sign in with Google",
                                ar: "تسجيل الدخول عبر Google",
                                ku: "چوونەژوورەوە بە Google"
                            ))
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
                    .disabled(authViewModel.isLoading || !hasAcceptedTerms)
                }
                .padding(.horizontal)
                .opacity(hasAcceptedTerms ? 1.0 : 0.5)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localizedText(
                        en: "Close",
                        ar: "إغلاق",
                        ku: "داخستن"
                    )) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showWhatsAppLogin) {
                WhatsAppLoginView()
            }
            .sheet(isPresented: $showEmailLogin) {
                EmailLoginView()
            }
            .sheet(isPresented: $showTerms) {
                TermsView()
            }
            .onChange(of: authViewModel.isAuthenticated) { isAuthenticated in
                if isAuthenticated {
                    dismiss()
                }
            }
            .alert(localizedText(
                en: "Sign In Error",
                ar: "خطأ في تسجيل الدخول",
                ku: "هەڵەی چوونەژوورەوە"
            ), isPresented: $showErrorAlert) {
                Button(localizedText(
                    en: "OK",
                    ar: "حسنًا",
                    ku: "باشە"
                ), role: .cancel) {
                    authViewModel.errorMessage = nil
                }
            } message: {
                Text(authViewModel.errorMessage ?? localizedText(
                    en: "An error occurred",
                    ar: "حدث خطأ",
                    ku: "هەڵەیەک ڕوویدا"
                ))
            }
        }
        .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
    }
}

struct EmailLoginView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSignUpMode = false
    @State private var showForgotPassword = false

    private var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var trimmedEmail: String { email.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var isRTL: Bool { authIsRTL(appSettings.language) }

    private func localizedText(en: String, ar: String, ku: String) -> String {
        authLocalizedText(language: appSettings.language, en: en, ar: ar, ku: ku)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 58))
                    .foregroundColor(.blue)
                    .padding(.top, 24)

                Text(isSignUpMode
                    ? localizedText(en: "Sign up with Email", ar: "إنشاء حساب بالبريد الإلكتروني", ku: "تۆمارکردن بە ئیمەیڵ")
                    : localizedText(en: "Sign in with Email", ar: "تسجيل الدخول بالبريد الإلكتروني", ku: "چوونەژوورەوە بە ئیمەیڵ")
                )
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Picker(localizedText(en: "Mode", ar: "الوضع", ku: "دۆخ"), selection: $isSignUpMode) {
                    Text(localizedText(en: "Sign In", ar: "تسجيل الدخول", ku: "چوونەژوورەوە")).tag(false)
                    Text(localizedText(en: "Sign Up", ar: "إنشاء حساب", ku: "تۆمارکردن")).tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                VStack(spacing: 12) {
                    if isSignUpMode {
                        TextField(localizedText(en: "Full Name", ar: "الاسم الكامل", ku: "ناوی تەواو"), text: $name)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                            .textContentType(nil)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }

                    TextField(localizedText(en: "Email", ar: "البريد الإلكتروني", ku: "ئیمەیڵ"), text: $email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.emailAddress)
                        .textContentType(nil)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    SecureField(localizedText(en: "Password", ar: "كلمة المرور", ku: "وشەی نهێنی"), text: $password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textContentType(nil)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    if isSignUpMode {
                        SecureField(localizedText(en: "Confirm Password", ar: "تأكيد كلمة المرور", ku: "دووبارەکردنەوەی وشەی نهێنی"), text: $confirmPassword)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .textContentType(nil)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)

                Button(action: {
                    Task {
                        let cleanEmail = trimmedEmail
                        if isSignUpMode {
                            guard password == confirmPassword else {
                                authViewModel.errorMessage = localizedText(
                                    en: "Passwords do not match.",
                                    ar: "كلمتا المرور غير متطابقتين.",
                                    ku: "وشە نهێنییەکان یەک ناگرن."
                                )
                                return
                            }

                            await authViewModel.registerWithEmail(
                                name: trimmedName,
                                email: cleanEmail,
                                password: password
                            )

                            if authViewModel.successMessage != nil {
                                isSignUpMode = false
                                password = ""
                                confirmPassword = ""
                            }
                        } else {
                            await authViewModel.loginWithEmail(email: cleanEmail, password: password)
                            if authViewModel.isAuthenticated {
                                dismiss()
                            }
                        }
                    }
                }) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(isSignUpMode
                            ? localizedText(en: "Create Account", ar: "إنشاء حساب", ku: "دروستکردنی هەژمار")
                            : localizedText(en: "Continue", ar: "متابعة", ku: "بەردەوامبە")
                        )
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isPrimaryActionDisabled ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .disabled(isPrimaryActionDisabled || authViewModel.isLoading)

                if let success = authViewModel.successMessage {
                    Text(success)
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }

                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }

                if shouldShowResendVerification {
                    Button(action: {
                        Task {
                            await authViewModel.resendVerificationEmail(
                                email: trimmedEmail
                            )
                        }
                    }) {
                        Text(authViewModel.isLoading
                            ? localizedText(en: "Sending...", ar: "جارٍ الإرسال...", ku: "نێردراوە...")
                            : localizedText(en: "Resend verification email", ar: "إعادة إرسال رسالة التحقق", ku: "دووبارە ناردنی ئیمەیڵی پشتڕاستکردنەوە")
                        )
                            .font(.footnote)
                            .fontWeight(.semibold)
                    }
                    .disabled(authViewModel.isLoading)
                }

                if !isSignUpMode {
                    Button(localizedText(
                        en: "Forgot password?",
                        ar: "هل نسيت كلمة المرور؟",
                        ku: "وشەی نهێنیت لەبیرکردووە؟"
                    )) {
                        showForgotPassword = true
                    }
                    .font(.footnote)
                }

                Button(isSignUpMode
                    ? localizedText(en: "Already have an account? Sign In", ar: "لديك حساب بالفعل؟ سجّل الدخول", ku: "هەژمارت هەیە؟ بچۆ ژوورەوە")
                    : localizedText(en: "Need an account? Sign Up", ar: "تحتاج إلى حساب؟ أنشئ حسابًا", ku: "پێویستت بە هەژمارە؟ تۆماربکە")
                ) {
                    isSignUpMode.toggle()
                    authViewModel.errorMessage = nil
                    authViewModel.successMessage = nil
                }
                .font(.footnote)
                .padding(.top, 4)

                Spacer()
            }
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localizedText(
                        en: "Cancel",
                        ar: "إلغاء",
                        ku: "هەڵوەشاندنەوە"
                    )) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView(prefilledEmail: trimmedEmail)
            }
        }
        .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
    }

    private var isPrimaryActionDisabled: Bool {
        if isSignUpMode {
            return trimmedName.isEmpty
                || trimmedEmail.isEmpty
                || password.isEmpty
                || confirmPassword.isEmpty
        }

        return trimmedEmail.isEmpty
            || password.isEmpty
    }

    private var shouldShowResendVerification: Bool {
        guard !isSignUpMode else { return false }
        guard !trimmedEmail.isEmpty else { return false }
        guard let message = authViewModel.errorMessage else { return false }
        return message.localizedCaseInsensitiveContains("email not verified")
    }
}

struct ForgotPasswordView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss

    @State private var email: String
    @State private var code = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var step: Int = 1

    init(prefilledEmail: String) {
        _email = State(initialValue: prefilledEmail)
    }

    private var isRTL: Bool { authIsRTL(appSettings.language) }

    private func localizedText(en: String, ar: String, ku: String) -> String {
        authLocalizedText(language: appSettings.language, en: en, ar: ar, ku: ku)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    Text(localizedText(
                        en: "Reset password",
                        ar: "إعادة تعيين كلمة المرور",
                        ku: "نوێکردنەوەی وشەی نهێنی"
                    ))
                        .font(.title3)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    if step == 1 {
                        TextField(localizedText(en: "Email", ar: "البريد الإلكتروني", ku: "ئیمەیڵ"), text: $email)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)

                        Button(authViewModel.isLoading
                            ? localizedText(en: "Sending...", ar: "جارٍ الإرسال...", ku: "نێردراوە...")
                            : localizedText(en: "Send Code", ar: "إرسال الرمز", ku: "ناردنی کۆد")
                        ) {
                            Task {
                                await authViewModel.sendForgotPasswordCode(
                                    email: email.trimmingCharacters(in: .whitespacesAndNewlines)
                                )
                                if authViewModel.errorMessage == nil {
                                    step = 2
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .disabled(email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || authViewModel.isLoading)
                    }

                    if step == 2 {
                        TextField(localizedText(en: "6-digit code", ar: "رمز من 6 أرقام", ku: "کۆدی 6 ژمارەیی"), text: $code)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)

                        SecureField(localizedText(en: "New password", ar: "كلمة المرور الجديدة", ku: "وشەی نهێنی نوێ"), text: $newPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)

                        SecureField(localizedText(en: "Confirm new password", ar: "تأكيد كلمة المرور الجديدة", ku: "دووبارەکردنەوەی وشەی نهێنی نوێ"), text: $confirmPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)

                        Button(authViewModel.isLoading
                            ? localizedText(en: "Updating...", ar: "جارٍ التحديث...", ku: "نوێدەکرێتەوە...")
                            : localizedText(en: "Reset Password", ar: "إعادة تعيين كلمة المرور", ku: "نوێکردنەوەی وشەی نهێنی")
                        ) {
                            Task {
                                guard newPassword == confirmPassword else {
                                    authViewModel.errorMessage = localizedText(
                                        en: "Passwords do not match.",
                                        ar: "كلمتا المرور غير متطابقتين.",
                                        ku: "وشە نهێنییەکان یەک ناگرن."
                                    )
                                    return
                                }

                                let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
                                let ok = await authViewModel.confirmResetCode(email: cleanEmail, code: code)
                                if !ok { return }

                                let resetOk = await authViewModel.resetPassword(email: cleanEmail, newPassword: newPassword)
                                if resetOk {
                                    dismiss()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isResetDisabled ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .disabled(isResetDisabled || authViewModel.isLoading)
                    }

                    if let success = authViewModel.successMessage {
                        Text(success)
                            .font(.caption)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                    }

                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(localizedText(
                        en: "Close",
                        ar: "إغلاق",
                        ku: "داخستن"
                    )) { dismiss() }
                }
            }
        }
        .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
    }

    private var isResetDisabled: Bool {
        code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || newPassword.isEmpty
            || confirmPassword.isEmpty
    }
}

struct WhatsAppLoginView: View {
    @EnvironmentObject var authViewModel: AuthenticationViewModel
    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) var dismiss
    @State private var phoneNumber = ""

    private var isRTL: Bool { authIsRTL(appSettings.language) }

    private func localizedText(en: String, ar: String, ku: String) -> String {
        authLocalizedText(language: appSettings.language, en: en, ar: ar, ku: ku)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "message.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .padding(.top, 40)
                
                Text(localizedText(
                    en: "Sign in with WhatsApp",
                    ar: "تسجيل الدخول عبر واتساب",
                    ku: "چوونەژوورەوە بە واتساپ"
                ))
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(localizedText(
                    en: "Enter your WhatsApp number to continue",
                    ar: "أدخل رقم واتساب للمتابعة",
                    ku: "ژمارەی واتساپەکەت بنووسە بۆ بەردەوامبوون"
                ))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(localizedText(
                        en: "Phone Number",
                        ar: "رقم الهاتف",
                        ku: "ژمارەی مۆبایل"
                    ))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        Text("🇮🇶 +964")
                            .foregroundColor(.secondary)
                        
                        TextField(localizedText(en: "750 123 4567", ar: "750 123 4567", ku: "750 123 4567"), text: $phoneNumber)
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
                        Text(localizedText(
                            en: "Continue",
                            ar: "متابعة",
                            ku: "بەردەوامبە"
                        ))
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
                    Button(localizedText(
                        en: "Cancel",
                        ar: "إلغاء",
                        ku: "هەڵوەشاندنەوە"
                    )) {
                        dismiss()
                    }
                }
            }
        }
        .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
    }
}

struct TermsView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        sectionHeader("1. Acceptance of Terms")
                        bodyText("By accessing or using Souqira, you agree to be bound by these Terms and Conditions. If you do not agree, please do not use the app.")

                        sectionHeader("2. Use of the Platform")
                        bodyText("Souqira is a marketplace platform for buying, selling, and discovering businesses. You agree to use the platform lawfully and not to post content that is false, misleading, illegal, or harmful.")

                        sectionHeader("3. User Content")
                        bodyText("You are solely responsible for any listings, messages, or content you post. Souqira reserves the right to remove content that violates these terms or applicable law.")

                        sectionHeader("4. Prohibited Content")
                        bodyText("You may not post listings that involve illegal goods or services, adult content, spam, or content that infringes on third-party rights.")

                        sectionHeader("5. Reporting & Moderation")
                        bodyText("Users may report listings that violate these terms. Souqira reviews reports and may remove content or suspend accounts without prior notice.")

                        sectionHeader("6. Blocking Users")
                        bodyText("You may block other users at any time. Blocked users will not be able to contact you through the platform.")
                    }
                    Group {
                        sectionHeader("7. Account Responsibility")
                        bodyText("You are responsible for maintaining the confidentiality of your account credentials. Notify us immediately of any unauthorized use of your account.")

                        sectionHeader("8. Privacy")
                        bodyText("Your use of Souqira is also governed by our Privacy Policy. We collect and process data only as described therein.")

                        sectionHeader("9. Intellectual Property")
                        bodyText("All content, trademarks, and data on Souqira are the property of Souqira or its licensors. You may not copy, reproduce, or distribute any content without permission.")

                        sectionHeader("10. Limitation of Liability")
                        bodyText("Souqira is provided \"as is\". We are not liable for any losses or damages arising from your use of the platform.")

                        sectionHeader("11. Changes to Terms")
                        bodyText("We may update these terms at any time. Continued use of the app after changes constitutes acceptance of the new terms.")

                        sectionHeader("12. Contact")
                        bodyText("For questions about these Terms, contact us at support@souqira.com.")
                    }
                }
                .padding(20)
            }
            .navigationTitle("Terms & Conditions")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(text).font(.headline).foregroundColor(.primary)
    }

    private func bodyText(_ text: String) -> some View {
        Text(text).font(.body).foregroundColor(.secondary).lineSpacing(4)
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationViewModel())
    .environmentObject(AppSettings())
}
