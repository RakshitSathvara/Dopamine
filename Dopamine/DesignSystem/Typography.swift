//
//  Typography.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

extension Font {
    // MARK: - Display
    static let displayLarge = Font.system(size: 40, weight: .bold, design: .rounded)
    static let displayMedium = Font.system(size: 32, weight: .bold, design: .rounded)

    // MARK: - Headings
    static let h1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let h2 = Font.system(size: 24, weight: .semibold, design: .rounded)
    static let h3 = Font.system(size: 20, weight: .semibold, design: .rounded)

    // MARK: - Body
    static let bodyLarge = Font.system(size: 18, weight: .regular, design: .default)
    static let bodyRegular = Font.system(size: 16, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)

    // MARK: - Labels
    static let caption = Font.system(size: 12, weight: .medium, design: .default)
    static let overline = Font.system(size: 11, weight: .semibold, design: .default)

    // MARK: - Special
    static let code = Font.system(size: 14, weight: .regular, design: .monospaced)
}
