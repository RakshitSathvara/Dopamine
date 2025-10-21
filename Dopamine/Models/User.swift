//
//  User.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import Foundation

struct UserStatistics: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var totalActivitiesCompleted: Int
    var totalMinutes: Int
}

struct UserPreferences: Codable {
    var notificationsEnabled: Bool
    var darkMode: Bool
    var dailyGoal: Int // in minutes
}

struct User: Identifiable, Codable {
    let id: String
    let email: String
    var name: String
    let createdAt: Date
    var lastLoginAt: Date
    var statistics: UserStatistics
    var preferences: UserPreferences

    static let sample = User(
        id: "user_1",
        email: "sarah@example.com",
        name: "Sarah",
        createdAt: Date().addingTimeInterval(-30 * 24 * 60 * 60), // 30 days ago
        lastLoginAt: Date(),
        statistics: UserStatistics(
            currentStreak: 7,
            longestStreak: 14,
            totalActivitiesCompleted: 42,
            totalMinutes: 1850
        ),
        preferences: UserPreferences(
            notificationsEnabled: true,
            darkMode: false,
            dailyGoal: 120
        )
    )
}
