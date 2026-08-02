//
//  AppSettings.swift
//  Souqira
//
//  Created on 17/02/2026
//

import Foundation
import SwiftUI

class AppSettings: ObservableObject {
    @AppStorage("appLanguage") var language: String = ""
    @AppStorage("isDarkMode") var isDarkMode: Bool = false
    
    init() {
        // Auto-detect device language on first launch
        if language.isEmpty {
            language = detectDeviceLanguage()
        }
    }
    
    var isRTL: Bool {
        return language == "ar" || language == "ku"
    }
    
    func setLanguage(_ lang: String) {
        language = lang
    }
    
    private func detectDeviceLanguage() -> String {
        let deviceLanguage = Locale.preferredLanguages.first ?? "en"
        
        // Check for Kurdish variants
        if deviceLanguage.starts(with: "ku") || deviceLanguage.starts(with: "ckb") {
            return "ku" // Kurdish (Sorani)
        }
        // Check for Arabic
        else if deviceLanguage.starts(with: "ar") {
            return "ar"
        }
        // Default to English
        else {
            return "en"
        }
    }
}

// MARK: - Design System

struct DesignSystem {
    struct Colors {
        static let primary = Color(hex: "#0A4F66")
        static let primaryLight = Color(hex: "#0F6A86")
        static let primaryDark = Color(hex: "#083A4D")

        static let secondary = Color(hex: "#2B7EA1")
        static let secondaryLight = Color(hex: "#4F9DC0")
        static let secondaryDark = Color(hex: "#1E5F7B")

        static let accent = Color(hex: "#0F6A86")

        static let success = Color(hex: "#10B981")
        static let warning = Color(hex: "#F59E0B")
        static let error = Color(hex: "#EF4444")

        static let gray50 = Color(hex: "#F7FAFC")
        static let gray100 = Color(hex: "#EEF3F7")
        static let gray200 = Color(hex: "#DCE6EE")
        static let gray300 = Color(hex: "#C5D3DF")
        static let gray400 = Color(hex: "#94A9BC")
        static let gray500 = Color(hex: "#6B8399")
        static let gray600 = Color(hex: "#4A647A")
        static let gray700 = Color(hex: "#314A60")
        static let gray800 = Color(hex: "#1C3347")
        static let gray900 = Color(hex: "#0C2235")

        static let canvas = Color(hex: "#F2F6F9")
        static let card = Color.white

        static let primaryGradient = LinearGradient(
            colors: [primary, primaryLight],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let accentGradient = LinearGradient(
            colors: [secondary, primaryLight],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let softGradient = LinearGradient(
            colors: [Color(hex: "#EEF4F8"), Color(hex: "#E3EDF4"), Color(hex: "#F8FBFD")],
            startPoint: .top,
            endPoint: .bottomTrailing
        )
    }

    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }

    struct Radius {
        static let none: CGFloat = 0
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let xxl: CGFloat = 24
        static let full: CGFloat = 999
    }

    struct Shadows {
        static let sm = Shadow(color: Color(hex: "#0F3D3E").opacity(0.06), radius: 4, x: 0, y: 2)
        static let md = Shadow(color: Color(hex: "#0F3D3E").opacity(0.08), radius: 10, x: 0, y: 4)
        static let lg = Shadow(color: Color(hex: "#0F3D3E").opacity(0.12), radius: 18, x: 0, y: 8)
        static let xl = Shadow(color: Color(hex: "#0F3D3E").opacity(0.14), radius: 24, x: 0, y: 12)
        static let xxl = Shadow(color: Color(hex: "#0F3D3E").opacity(0.18), radius: 30, x: 0, y: 16)
    }

    struct Typography {
        static let display = Font.system(size: 56, weight: .bold, design: .serif)
        static let h1 = Font.system(size: 40, weight: .bold, design: .serif)
        static let h2 = Font.system(size: 32, weight: .bold, design: .serif)
        static let h3 = Font.system(size: 24, weight: .semibold, design: .serif)
        static let h4 = Font.system(size: 20, weight: .semibold, design: .default)
        static let body = Font.system(size: 16, weight: .regular, design: .rounded)
        static let bodyBold = Font.system(size: 16, weight: .semibold)
        static let small = Font.system(size: 14, weight: .regular, design: .rounded)
        static let tiny = Font.system(size: 12, weight: .regular, design: .rounded)
    }
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

struct SouqiraPatternBackground: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                LinearGradient(
                    colors: [
                        DesignSystem.Colors.canvas,
                        DesignSystem.Colors.gray100,
                        Color.white
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Circle()
                    .fill(DesignSystem.Colors.primary.opacity(0.08))
                    .frame(width: width * 0.9, height: width * 0.9)
                    .offset(x: -width * 0.5, y: -height * 0.1)

                Circle()
                    .fill(DesignSystem.Colors.secondary.opacity(0.1))
                    .frame(width: width * 0.7, height: width * 0.7)
                    .offset(x: width * 0.4, y: -height * 0.25)

                Circle()
                    .stroke(DesignSystem.Colors.primary.opacity(0.08), lineWidth: 1)
                    .frame(width: width * 0.6, height: width * 0.6)
                    .offset(x: width * 0.12, y: -height * 0.2)

                Path { path in
                    let y = height * 0.32
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addCurve(
                        to: CGPoint(x: width, y: y + 8),
                        control1: CGPoint(x: width * 0.25, y: y - 24),
                        control2: CGPoint(x: width * 0.7, y: y + 30)
                    )
                }
                .stroke(DesignSystem.Colors.primary.opacity(0.12), lineWidth: 2)

                Path { path in
                    let y = height * 0.36
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addCurve(
                        to: CGPoint(x: width, y: y + 6),
                        control1: CGPoint(x: width * 0.2, y: y + 18),
                        control2: CGPoint(x: width * 0.8, y: y - 16)
                    )
                }
                .stroke(DesignSystem.Colors.secondary.opacity(0.12), lineWidth: 1)
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct CardModifier: ViewModifier {
    var padding: CGFloat = DesignSystem.Spacing.md
    var backgroundColor: Color = DesignSystem.Colors.card
    var shadow: Shadow = DesignSystem.Shadows.md

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(DesignSystem.Radius.xl)
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var isLoading: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.bodyBold)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                    .fill(
                        configuration.isPressed
                            ? AnyShapeStyle(DesignSystem.Colors.primaryDark)
                            : AnyShapeStyle(DesignSystem.Colors.primaryGradient)
                    )
            )
            .cornerRadius(DesignSystem.Radius.xl)
            .shadow(color: DesignSystem.Colors.primary.opacity(0.22), radius: 14, x: 0, y: 8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .opacity(isLoading ? 0.6 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.bodyBold)
            .foregroundColor(DesignSystem.Colors.primaryDark)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.gray100)
            .cornerRadius(DesignSystem.Radius.xl)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.xl)
                    .stroke(DesignSystem.Colors.gray200, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.bodyBold)
            .foregroundColor(DesignSystem.Colors.primaryDark)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                configuration.isPressed
                    ? DesignSystem.Colors.gray100
                    : Color.clear
            )
            .cornerRadius(DesignSystem.Radius.xl)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct InputFieldModifier: ViewModifier {
    var isFocused: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.gray50)
            .cornerRadius(DesignSystem.Radius.lg)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.lg)
                    .stroke(
                        isFocused ? DesignSystem.Colors.primary : Color.clear,
                        lineWidth: 2
                    )
            )
            .shadow(color: isFocused ? DesignSystem.Colors.primary.opacity(0.2) : .clear, radius: 8)
            .animation(.spring(response: 0.3), value: isFocused)
    }
}

struct BadgeModifier: ViewModifier {
    var color: Color = DesignSystem.Colors.primary

    func body(content: Content) -> some View {
        content
            .font(DesignSystem.Typography.tiny)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(color)
            .cornerRadius(DesignSystem.Radius.full)
    }
}

extension View {
    func card(
        padding: CGFloat = DesignSystem.Spacing.md,
        backgroundColor: Color = .white,
        shadow: Shadow = DesignSystem.Shadows.md
    ) -> some View {
        modifier(CardModifier(padding: padding, backgroundColor: backgroundColor, shadow: shadow))
    }

    func inputField(isFocused: Bool = false) -> some View {
        modifier(InputFieldModifier(isFocused: isFocused))
    }

    func badge(color: Color = DesignSystem.Colors.primary) -> some View {
        modifier(BadgeModifier(color: color))
    }
}
