//
//  Colors.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

extension Color {
    // MARK: - Text Colors
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color.gray.opacity(0.6)

    // MARK: - Background Gradients
    struct Gradients {
        // Light Mode
        static let lightPrimary = LinearGradient(
            colors: [
                Color(hex: "#E0E7FF"), // Light Indigo
                Color(hex: "#F5F3FF"), // Light Purple
                Color(hex: "#FDF4FF")  // Light Pink
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let lightAccent = LinearGradient(
            colors: [
                Color(hex: "#DBEAFE"), // Light Blue
                Color(hex: "#E0E7FF")  // Light Indigo
            ],
            startPoint: .top,
            endPoint: .bottom
        )

        // Dark Mode
        static let darkPrimary = LinearGradient(
            colors: [
                Color(hex: "#1F2937"), // Dark Gray
                Color(hex: "#111827"), // Darker Gray
                Color(hex: "#0F172A")  // Almost Black
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let darkAccent = LinearGradient(
            colors: [
                Color(hex: "#312E81"), // Dark Indigo
                Color(hex: "#1E1B4B")  // Darker Indigo
            ],
            startPoint: .top,
            endPoint: .bottom
        )

        // Vibrant gradients for glass backgrounds
        static let purple = LinearGradient(
            colors: [
                Color.purple.opacity(0.15),
                Color.blue.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let blue = LinearGradient(
            colors: [
                Color.blue.opacity(0.10),
                Color.purple.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let vibrant = LinearGradient(
            colors: [
                Color.purple,
                Color.blue,
                Color.pink
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Glass Tints
    static let glassPrimary = Color(hex: "#8B5CF6").opacity(0.15)
    static let glassSecondary = Color(hex: "#3B82F6").opacity(0.12)

    // MARK: - Border Colors
    static let borderLight = Color.white.opacity(0.2)
    static let borderAccent = Color.white.opacity(0.4)
    static let borderDark = Color(hex: "#8B5CF6").opacity(0.5)

    // MARK: - Semantic Colors
    static let success = Color.green
    static let error = Color.red
    static let warning = Color.orange
    static let info = Color.blue

    // MARK: - Hex Initializer
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
