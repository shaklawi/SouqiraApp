//
//  DesignSystemDemoView.swift
//  Souqira
//
//  Created on 18/02/2026
//

import SwiftUI

/// Demo view showing how to use the Tailwind-inspired Design System
struct DesignSystemDemoView: View {
    @State private var textInput = ""
    @State private var isInputFocused = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xl) {
                
                // MARK: - Typography Examples
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Typography")
                        .font(DesignSystem.Typography.h2)
                    
                    Text("Display Text")
                        .font(DesignSystem.Typography.display)
                    
                    Text("Heading 1")
                        .font(DesignSystem.Typography.h1)
                    
                    Text("Heading 2")
                        .font(DesignSystem.Typography.h2)
                    
                    Text("Heading 3")
                        .font(DesignSystem.Typography.h3)
                    
                    Text("Body text - Regular paragraph text goes here")
                        .font(DesignSystem.Typography.body)
                    
                    Text("Small text for captions")
                        .font(DesignSystem.Typography.small)
                        .foregroundColor(DesignSystem.Colors.gray500)
                }
                .card()
                
                // MARK: - Button Examples
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Buttons")
                        .font(DesignSystem.Typography.h3)
                    
                    Button("Primary Button") {
                        print("Primary tapped")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button("Secondary Button") {
                        print("Secondary tapped")
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Button("Ghost Button") {
                        print("Ghost tapped")
                    }
                    .buttonStyle(GhostButtonStyle())
                    
                    Button("Loading Button") {
                        print("Loading tapped")
                    }
                    .buttonStyle(PrimaryButtonStyle(isLoading: true))
                    .disabled(true)
                }
                .card()
                
                // MARK: - Input Field Examples
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Input Fields")
                        .font(DesignSystem.Typography.h3)
                    
                    TextField("Search businesses...", text: $textInput)
                        .inputField(isFocused: isInputFocused)
                        .onTapGesture {
                            isInputFocused = true
                        }
                    
                    TextField("Normal input", text: .constant(""))
                        .inputField()
                }
                .card()
                
                // MARK: - Badge Examples
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Badges")
                        .font(DesignSystem.Typography.h3)
                    
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Text("Featured")
                            .badge(color: DesignSystem.Colors.primary)
                        
                        Text("New")
                            .badge(color: DesignSystem.Colors.success)
                        
                        Text("Sale")
                            .badge(color: DesignSystem.Colors.error)
                        
                        Text("Hot")
                            .badge(color: DesignSystem.Colors.warning)
                    }
                }
                .card()
                
                // MARK: - Card Examples
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Cards")
                        .font(DesignSystem.Typography.h3)
                    
                    // Default card
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Default Card")
                            .font(DesignSystem.Typography.h4)
                        Text("This is a card with default shadow")
                            .font(DesignSystem.Typography.small)
                            .foregroundColor(DesignSystem.Colors.gray500)
                    }
                    .card()
                    
                    // Card with large shadow
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Large Shadow Card")
                            .font(DesignSystem.Typography.h4)
                        Text("This card has a larger shadow for emphasis")
                            .font(DesignSystem.Typography.small)
                            .foregroundColor(DesignSystem.Colors.gray500)
                    }
                    .card(shadow: DesignSystem.Shadows.xl)
                    
                    // Colored background card
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Colored Card")
                            .font(DesignSystem.Typography.h4)
                            .foregroundColor(.white)
                        Text("This card has a gradient background")
                            .font(DesignSystem.Typography.small)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .card(
                        backgroundColor: .clear,
                        shadow: DesignSystem.Shadows.lg
                    )
                    .background(DesignSystem.Colors.primaryGradient)
                    .cornerRadius(DesignSystem.Radius.xl)
                }
                
                // MARK: - Color Palette
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Color Palette")
                        .font(DesignSystem.Typography.h3)
                    
                    // Primary colors
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        ColorSwatch(color: DesignSystem.Colors.primaryLight, name: "Primary Light")
                        ColorSwatch(color: DesignSystem.Colors.primary, name: "Primary")
                        ColorSwatch(color: DesignSystem.Colors.primaryDark, name: "Primary Dark")
                    }
                    
                    // Secondary colors
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        ColorSwatch(color: DesignSystem.Colors.secondaryLight, name: "Secondary Light")
                        ColorSwatch(color: DesignSystem.Colors.secondary, name: "Secondary")
                        ColorSwatch(color: DesignSystem.Colors.secondaryDark, name: "Secondary Dark")
                    }
                    
                    // Status colors
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        ColorSwatch(color: DesignSystem.Colors.success, name: "Success")
                        ColorSwatch(color: DesignSystem.Colors.warning, name: "Warning")
                        ColorSwatch(color: DesignSystem.Colors.error, name: "Error")
                    }
                }
                .card()
                
                // MARK: - Spacing Examples
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Spacing Scale")
                        .font(DesignSystem.Typography.h3)
                    
                    SpacingExample(size: DesignSystem.Spacing.xs, label: "XS (4px)")
                    SpacingExample(size: DesignSystem.Spacing.sm, label: "SM (8px)")
                    SpacingExample(size: DesignSystem.Spacing.md, label: "MD (16px)")
                    SpacingExample(size: DesignSystem.Spacing.lg, label: "LG (24px)")
                    SpacingExample(size: DesignSystem.Spacing.xl, label: "XL (32px)")
                    SpacingExample(size: DesignSystem.Spacing.xxl, label: "XXL (48px)")
                }
                .card()
            }
            .padding(DesignSystem.Spacing.md)
        }
        .background(DesignSystem.Colors.softGradient)
        .navigationTitle("Design System")
    }
}

// MARK: - Helper Views

struct ColorSwatch: View {
    let color: Color
    let name: String
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                .fill(color)
                .frame(height: 60)
            
            Text(name)
                .font(DesignSystem.Typography.tiny)
                .foregroundColor(DesignSystem.Colors.gray600)
        }
    }
}

struct SpacingExample: View {
    let size: CGFloat
    let label: String
    
    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Text(label)
                .font(DesignSystem.Typography.small)
                .frame(width: 80, alignment: .leading)
            
            Rectangle()
                .fill(DesignSystem.Colors.primary)
                .frame(width: size, height: 20)
                .cornerRadius(DesignSystem.Radius.sm)
        }
    }
}

#Preview {
    NavigationStack {
        DesignSystemDemoView()
    }
}
