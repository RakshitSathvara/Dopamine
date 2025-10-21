//
//  Activity.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import Foundation

enum ActivityCategory: String, Codable, CaseIterable {
    case starters
    case mains
    case sides
    case desserts
    case special

    var displayName: String {
        switch self {
        case .starters: return "Starters"
        case .mains: return "Mains"
        case .sides: return "Sides"
        case .desserts: return "Desserts"
        case .special: return "Special"
        }
    }
}

enum ActivityType: String, Codable, CaseIterable {
    case focus
    case creativity
    case productivity
    case wellness
    case mindfulness
    case energy

    var displayName: String {
        self.rawValue.capitalized
    }

    var icon: String {
        switch self {
        case .focus: return "target"
        case .creativity: return "paintbrush.fill"
        case .productivity: return "chart.line.uptrend.xyaxis"
        case .wellness: return "heart.fill"
        case .mindfulness: return "brain.head.profile"
        case .energy: return "bolt.fill"
        }
    }
}

enum Difficulty: String, Codable {
    case easy
    case medium
    case hard

    var displayName: String {
        self.rawValue.capitalized
    }
}

struct Activity: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let category: ActivityCategory
    let duration: Int // in minutes
    let difficulty: Difficulty
    let benefits: [String]
    let icon: String
    let activityType: ActivityType?

    static func == (lhs: Activity, rhs: Activity) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Static Data
extension Activity {
    static let sampleActivities: [Activity] = [
        // Starters
        Activity(
            id: "1",
            name: "5-Min Breathing",
            description: "Deep breathing exercise to center your mind and reduce stress",
            category: .starters,
            duration: 5,
            difficulty: .easy,
            benefits: ["Focus", "Calm", "Energy"],
            icon: "🧘",
            activityType: .mindfulness
        ),
        Activity(
            id: "2",
            name: "Morning Stretch",
            description: "Gentle stretching routine to wake up your body",
            category: .starters,
            duration: 10,
            difficulty: .easy,
            benefits: ["Energy", "Flexibility", "Wellness"],
            icon: "💪",
            activityType: .wellness
        ),
        Activity(
            id: "3",
            name: "Morning Meditation",
            description: "Start your day with mindful meditation",
            category: .starters,
            duration: 15,
            difficulty: .easy,
            benefits: ["Focus", "Peace", "Clarity"],
            icon: "🧘",
            activityType: .focus
        ),

        // Mains
        Activity(
            id: "4",
            name: "Deep Work Session",
            description: "90 minutes of focused, uninterrupted work",
            category: .mains,
            duration: 90,
            difficulty: .hard,
            benefits: ["Productivity", "Achievement", "Growth"],
            icon: "💻",
            activityType: .productivity
        ),
        Activity(
            id: "5",
            name: "Creative Writing",
            description: "Express yourself through creative writing",
            category: .mains,
            duration: 60,
            difficulty: .medium,
            benefits: ["Creativity", "Expression", "Flow"],
            icon: "✍️",
            activityType: .creativity
        ),
        Activity(
            id: "6",
            name: "Learning Session",
            description: "Study something new and expand your knowledge",
            category: .mains,
            duration: 45,
            difficulty: .medium,
            benefits: ["Knowledge", "Growth", "Achievement"],
            icon: "📚",
            activityType: .focus
        ),

        // Sides
        Activity(
            id: "7",
            name: "Quick Walk",
            description: "15-minute walk to refresh your mind",
            category: .sides,
            duration: 15,
            difficulty: .easy,
            benefits: ["Energy", "Health", "Clarity"],
            icon: "🚶",
            activityType: .energy
        ),
        Activity(
            id: "8",
            name: "Hydration Break",
            description: "Drink water and take a mindful break",
            category: .sides,
            duration: 5,
            difficulty: .easy,
            benefits: ["Health", "Energy", "Wellness"],
            icon: "💧",
            activityType: .wellness
        ),
        Activity(
            id: "9",
            name: "Organize Space",
            description: "Tidy up your workspace for better focus",
            category: .sides,
            duration: 20,
            difficulty: .easy,
            benefits: ["Focus", "Order", "Clarity"],
            icon: "🧹",
            activityType: .productivity
        ),

        // Desserts
        Activity(
            id: "10",
            name: "Evening Reading",
            description: "Wind down with a good book",
            category: .desserts,
            duration: 30,
            difficulty: .easy,
            benefits: ["Relaxation", "Knowledge", "Peace"],
            icon: "📖",
            activityType: .mindfulness
        ),
        Activity(
            id: "11",
            name: "Gratitude Journal",
            description: "Reflect on three things you're grateful for",
            category: .desserts,
            duration: 10,
            difficulty: .easy,
            benefits: ["Positivity", "Peace", "Mindfulness"],
            icon: "📝",
            activityType: .mindfulness
        ),
        Activity(
            id: "12",
            name: "Evening Reflection",
            description: "Review your day and plan for tomorrow",
            category: .desserts,
            duration: 15,
            difficulty: .easy,
            benefits: ["Clarity", "Planning", "Peace"],
            icon: "🌙",
            activityType: .focus
        ),

        // Special
        Activity(
            id: "13",
            name: "Digital Detox Hour",
            description: "One hour completely away from screens",
            category: .special,
            duration: 60,
            difficulty: .medium,
            benefits: ["Mindfulness", "Peace", "Presence"],
            icon: "📵",
            activityType: .mindfulness
        ),
        Activity(
            id: "14",
            name: "Nature Connection",
            description: "Spend time outdoors connecting with nature",
            category: .special,
            duration: 45,
            difficulty: .easy,
            benefits: ["Peace", "Energy", "Wellness"],
            icon: "🌳",
            activityType: .wellness
        ),
        Activity(
            id: "15",
            name: "Creative Project",
            description: "Work on a personal creative project",
            category: .special,
            duration: 120,
            difficulty: .medium,
            benefits: ["Creativity", "Joy", "Achievement"],
            icon: "🎨",
            activityType: .creativity
        )
    ]

    static func activities(for category: ActivityCategory) -> [Activity] {
        sampleActivities.filter { $0.category == category }
    }
}
