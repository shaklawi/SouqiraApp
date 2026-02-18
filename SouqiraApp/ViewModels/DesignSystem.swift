//
//  DesignSystem.swift
//  Souqira
//
//  Created on 18/02/2026
//

import SwiftUI

// MARK: - Design System (Tailwind-inspired)

struct DesignSystem {
    
    // MARK: - Colors (like Tailwind)
    struct Colors {
        // Primary colors
        static let primary = Color(hex: "#3B82F6") // blue-500
        static let primaryLight = Color(hex: "#60A5FA") // blue-400
        static let primaryDark = Color(hex: "#2563EB") // blue-600
        
        // Secondary colors
        static let secondary = Color(hex: "#8B5CF6") // violet-500
        static let secondaryLight = Color(hex: "#A78BFA") // violet-400
        static let secondaryDark = Color(hex: "#7C3AED") // violet-600
        
        // Success, Warning, Error
        static let success = Color(hex: "#10B981") // green-500
        static let warning = Color(hex: "#F59E0B") // amber-500
        static let error = Color(hex: "#EF4444") // red-500
        
        // Neutrals
        static let gray50 = Color(hex: "#F9FAFB")
        static let gray100 = Color(hex: "#F3F4F6")
        static let gray200 = Color(hex: "#E5E7EB")
        static let gray300 = Color(hex: "#D1D5DB")
        static let gray400 = Color(hex: "#9CA3AF")
        static let gray500 = Color(hex: "#6B7280")
        static let gray600 = Color(hex: "#4B5563")
        static let gray700 = Color(hex: "#374151")
        static let gray800 = Color(hex: "#1F2937")
        static let gray900 = Color(hex: "#111827")
        
        // Gradients
        static let primaryGradient = LinearGradient(
            colors: [primary, secondary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let softGradient = LinearGradient(
            colors: [Color.blue.opacity(0.05), Color.purple.opacity(0.05), Color.white],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Spacing (like Tailwind)
    struct Spacing {
        static let xs: CGFloat = 4    // space-1
        static let sm: CGFloat = 8    // space-2
        static let md: CGFloat = 16   // space-4
        static let lg: CGFloat = 24   // space-6
        static let xl: CGFloat = 32   // space-8
        static let xxl: CGFloat = 48  // space-12
        static let xxxl: CGFloat = 64 // space-16
    }
    
    // MARK: - Border Radius (like Tailwind)
    struct Radius {
        static let none: CGFloat = 0
        static let sm: CGFloat = 4    // rounded-sm
        static let md: CGFloat = 8    // rounded-md
        static let lg: CGFloat = 12   // rounded-lg
        static let xl: CGFloat = 16   // rounded-xl
        static let xxl: CGFloat = 24  // rounded-2xl
        static let full: CGFloat = 999 // rounded-full
    }
    
    // MARK: - Shadows (like Tailwind)
    struct Shadows {
        static let sm = Shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        static let md = Shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        static let lg = Shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        static let xl = Shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
        static let xxl = Shadow(color: .black.opacity(0.2), radius: 24, x: 0, y: 12)
    }
    
    // MARK: - Typography (like Tailwind)
    struct Typography {
        static let display = Font.system(size: 56, weight: .bold, design: .rounded)
        static let h1 = Font.system(size: 40, weight: .bold, design: .rounded)
        static let h2 = Font.system(size: 32, weight: .bold, design: .rounded)
        static let h3 = Font.system(size: 24, weight: .semibold, design: .rounded)
        static let h4 = Font.system(size: 20, weight: .semibold, design: .default)
        static let body = Font.system(size: 16, weight: .regular)
        static let bodyBold = Font.system(size: 16, weight: .semibold)
        static let small = Font.system(size: 14, weight: .regular)
        static let tiny = Font.system(size: 12, weight: .regular)
    }
}

// MARK: - Shadow Helper
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers (like Tailwind utilities)

// Card style (like Tailwind's card)
struct CardModifier: ViewModifier {
    var padding: CGFloat = DesignSystem.Spacing.md
    var backgroundColor: Color = .white
    var shadow: Shadow = DesignSystem.Shadows.md
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(DesignSystem.Radius.xl)
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

// Primary Button (like Tailwind's btn-primary)
struct PrimaryButtonStyle: ButtonStyle {
    var isLoading: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.bodyBold)
            .foregroundColor(.white)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(
                configuration.isPressed
                    ? DesignSystem.Colors.primaryDark
                    : DesignSystem.Colors.primaryGradient
            )
            .cornerRadius(DesignSystem.Radius.xl)
            .shadow(color: DesignSystem.Colors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .opacity(isLoading ? 0.6 : 1.0)
    }
}

// Secondary Button (like Tailwind's btn-secondary)
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.bodyBold)
            .foregroundColor(DesignSystem.Colors.primary)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.vertical, DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.gray100)
            .cornerRadius(DesignSystem.Radius.xl)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// Ghost Button (like Tailwind's btn-ghost)
struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(DesignSystem.Typography.bodyBold)
            .foregroundColor(DesignSystem.Colors.primary)
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

// Input Field (like Tailwind's input)
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

// Badge (like Tailwind's badge)
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

// MARK: - View Extensions
extension View {
    func card(padding: CGFloat = DesignSystem.Spacing.md,
             backgroundColor: Color = .white,
             shadow: Shadow = DesignSystem.Shadows.md) -> some View {
        modifier(CardModifier(padding: padding, backgroundColor: backgroundColor, shadow: shadow))
    }
    
    func inputField(isFocused: Bool = false) -> some View {
        modifier(InputFieldModifier(isFocused: isFocused))
    }
    
    func badge(color: Color = DesignSystem.Colors.primary) -> some View {
        modifier(BadgeModifier(color: color))
    }
}
