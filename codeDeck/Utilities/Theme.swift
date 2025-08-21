//
//  Theme.swift
//  codeDeck
//
//  Created by Meenakshi Gopalakrishnan on 2025-08-20.
//


import SwiftUI

// MARK: - Color Theme
extension Color {
    // Primary Colors
    static let matrixGreen = Color(red: 0/255, green: 255/255, blue: 65/255)     // #00FF41
    static let neonGreen = Color(red: 57/255, green: 255/255, blue: 20/255)      // #39FF14
    static let softGreen = Color(red: 102/255, green: 255/255, blue: 102/255)    // #66FF66
    static let mintGreen = Color(red: 0/255, green: 255/255, blue: 127/255)      // #00FF7F
    
    // Background Colors
    static let deepBlack = Color(red: 8/255, green: 8/255, blue: 8/255)          // #080808
    static let charcoal = Color(red: 18/255, green: 20/255, blue: 22/255)        // #121416
    static let darkGray = Color(red: 28/255, green: 32/255, blue: 36/255)        // #1C2024
    static let mediumGray = Color(red: 45/255, green: 50/255, blue: 55/255)      // #2D3237
    
    // Text Colors
    static let primaryText = Color.white
    static let secondaryText = Color(red: 180/255, green: 180/255, blue: 180/255) // #B4B4B4
    static let tertiaryText = Color(red: 120/255, green: 120/255, blue: 120/255)  // #787878
    
    // Accent Colors
    static let redAccent = Color(red: 255/255, green: 59/255, blue: 48/255)      // #FF3B30
    static let orangeAccent = Color(red: 255/255, green: 149/255, blue: 0/255)   // #FF9500
    static let blueAccent = Color(red: 0/255, green: 122/255, blue: 255/255)     // #007AFF
    
    // Status Colors
    static let successGreen = matrixGreen
    static let warningOrange = orangeAccent
    static let errorRed = redAccent
}

// MARK: - Typography System
struct FontStyle {
    // Display Fonts (for headers)
    static let displayLarge = Font.custom("SF Pro Display", size: 34, relativeTo: .largeTitle).weight(.heavy)
    static let displayMedium = Font.custom("SF Pro Display", size: 28, relativeTo: .title).weight(.bold)
    static let displaySmall = Font.custom("SF Pro Display", size: 24, relativeTo: .title2).weight(.semibold)
    
    // Body Fonts
    static let bodyLarge = Font.custom("SF Pro Text", size: 17, relativeTo: .body).weight(.medium)
    static let bodyMedium = Font.custom("SF Pro Text", size: 16, relativeTo: .body)
    static let bodySmall = Font.custom("SF Pro Text", size: 14, relativeTo: .callout)
    
    // Monospace (for code)
    static let codeLarge = Font.custom("SF Mono", size: 16, relativeTo: .body).weight(.medium)
    static let codeMedium = Font.custom("SF Mono", size: 14, relativeTo: .callout)
    static let codeSmall = Font.custom("SF Mono", size: 12, relativeTo: .caption)
    
    // Caption and Labels
    static let caption = Font.custom("SF Pro Text", size: 12, relativeTo: .caption).weight(.medium)
    static let footnote = Font.custom("SF Pro Text", size: 11, relativeTo: .footnote)
}

// MARK: - Modern Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FontStyle.bodyLarge)
            .foregroundColor(.deepBlack)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.matrixGreen)
                    .shadow(color: Color.matrixGreen.opacity(0.3), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(FontStyle.bodyMedium)
            .foregroundColor(.matrixGreen)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.matrixGreen, lineWidth: 1.5)
                    .background(Color.charcoal)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct IconButtonStyle: ButtonStyle {
    let color: Color
    let size: CGFloat
    
    init(color: Color = .matrixGreen, size: CGFloat = 44) {
        self.color = color
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size * 0.4, weight: .semibold))
            .foregroundColor(configuration.isPressed ? color.opacity(0.7) : color)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(Color.darkGray)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Modern Card Style
struct ModernCard<Content: View>: View {
    let content: Content
    let padding: CGFloat
    let cornerRadius: CGFloat
    
    init(padding: CGFloat = 20, cornerRadius: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.charcoal)
                    .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.darkGray, lineWidth: 1)
                    )
            )
    }
}

// MARK: - Difficulty Colors (Updated for theme)
extension Difficulty {
    var modernColor: Color {
        switch self {
        case .easy:
            return .softGreen
        case .medium:
            return .orangeAccent
        case .hard:
            return .redAccent
        }
    }
}

// MARK: - Status Colors (Updated for theme)
extension ProblemStatus {
    var modernColor: Color {
        switch self {
        case .completed:
            return .successGreen
        case .attempted:
            return .warningOrange
        }
    }
    
    var modernIcon: String {
        switch self {
        case .completed:
            return "checkmark.circle.fill"
        case .attempted:
            return "clock.circle.fill"
        }
    }
}
