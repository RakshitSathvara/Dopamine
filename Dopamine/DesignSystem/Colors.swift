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

    // MARK: - Theme-aware Background Colors
    static var appBackground: Color {
        Color(uiColor: .systemBackground)
    }

    static var secondaryBackground: Color {
        Color(uiColor: .secondarySystemBackground)
    }

    static var tertiaryBackground: Color {
        Color(uiColor: .tertiarySystemBackground)
    }

    // MARK: - Theme-aware Text Colors
    static var adaptiveWhite: Color {
        Color(uiColor: .label)
    }

    static var adaptiveSecondary: Color {
        Color(uiColor: .secondaryLabel)
    }

    static var adaptiveTertiary: Color {
        Color(uiColor: .tertiaryLabel)
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
