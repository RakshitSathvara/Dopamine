//
//  MenuCategory.swift
//  Dopamine
//
//  Created by Claude on 23/10/2025.
//

import Foundation

/// Represents a dopamine menu category with its metadata
struct MenuCategoryInfo: Codable {
    let title: String
    let description: String
    let icon: String
    let order: Int // For sorting categories in the UI

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case icon
        case order
    }
}

/// Complete menu configuration containing all categories
struct MenuConfiguration: Codable {
    let starters: MenuCategoryInfo
    let mains: MenuCategoryInfo
    let sides: MenuCategoryInfo
    let desserts: MenuCategoryInfo
    let specials: MenuCategoryInfo
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case starters
        case mains
        case sides
        case desserts
        case specials
        case updatedAt
    }

    /// Get category info by ActivityCategory enum
    func getCategoryInfo(for category: ActivityCategory) -> MenuCategoryInfo {
        switch category {
        case .starters:
            return starters
        case .mains:
            return mains
        case .sides:
            return sides
        case .desserts:
            return desserts
        case .special:
            return specials
        }
    }

    /// Get all categories as an ordered array
    func getAllCategories() -> [(category: ActivityCategory, info: MenuCategoryInfo)] {
        return [
            (.starters, starters),
            (.mains, mains),
            (.sides, sides),
            (.desserts, desserts),
            (.special, specials)
        ].sorted { $0.info.order < $1.info.order }
    }

    /// Default menu configuration for fallback
    static var `default`: MenuConfiguration {
        return MenuConfiguration(
            starters: MenuCategoryInfo(
                title: "Starters",
                description: "Quick 5–10 minute activities for a fast mood lift (like a short walk, stretching, or listening to a favorite song).",
                icon: "⚡",
                order: 1
            ),
            mains: MenuCategoryInfo(
                title: "Mains",
                description: "Longer, more fulfilling activities that provide a deeper sense of reward and satisfaction (like exercising, organizing a space, or cooking a meal).",
                icon: "🎯",
                order: 2
            ),
            sides: MenuCategoryInfo(
                title: "Sides",
                description: "Complementary actions that make tasks easier or more enjoyable (setting reminders, playing music while cleaning, etc.).",
                icon: "🔧",
                order: 3
            ),
            desserts: MenuCategoryInfo(
                title: "Desserts",
                description: "Pleasurable activities to enjoy in moderation (watching a show, social media time, snacks).",
                icon: "🍰",
                order: 4
            ),
            specials: MenuCategoryInfo(
                title: "Specials",
                description: "Planned or goal-oriented activities for extra motivation (journal sessions, hobby time, creative projects).",
                icon: "⭐",
                order: 5
            ),
            updatedAt: Date()
        )
    }
}
