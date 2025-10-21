//
//  Typography.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//
//  Typography system following Apple's Human Interface Guidelines
//  Uses SF Pro font family (system default on iOS)
//

import SwiftUI

extension Font {
    // MARK: - Display Styles
    // Large display text for hero sections and splash screens
    // Uses SF Pro Rounded for friendly, approachable aesthetic
    static let displayLarge = Font.system(size: 40, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 34, weight: .bold, design: .rounded)

    // MARK: - Title Styles
    // Following Apple's HIG title hierarchy
    // Uses SF Pro Rounded for headings to maintain design language
    static let largeTitle = Font.system(size: 34, weight: .regular, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)

    // MARK: - Headings (Custom Design System)
    // Maintains backward compatibility with existing design
    static let h1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let h2 = Font.system(size: 24, weight: .semibold, design: .rounded)
    static let h3 = Font.system(size: 20, weight: .semibold, design: .rounded)

    // MARK: - Body Styles
    // Following Apple's HIG body text hierarchy
    // Uses SF Pro (default) for optimal readability
    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)

    // Custom body sizes for design system
    static let bodyLarge = Font.system(size: 18, weight: .regular, design: .default)
    static let bodyRegular = Font.system(size: 16, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)

    // MARK: - Caption & Label Styles
    // Following Apple's HIG caption hierarchy
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption1 = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)

    // Custom caption for design system (medium weight for emphasis)
    static let caption = Font.system(size: 12, weight: .medium, design: .default)
    static let overline = Font.system(size: 11, weight: .semibold, design: .default)

    // MARK: - Special Purpose
    static let code = Font.system(size: 14, weight: .regular, design: .monospaced)

    // MARK: - Text Field & Input Styles
    // Optimized for form inputs and search fields
    static let textInput = Font.system(size: 17, weight: .regular, design: .default)
    static let textInputPlaceholder = Font.system(size: 17, weight: .regular, design: .default)
}
