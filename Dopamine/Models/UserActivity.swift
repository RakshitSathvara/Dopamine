//
//  UserActivity.swift
//  Dopamine
//
//  Model for user-created activities with category, title, duration, time, and date
//

import Foundation
import FirebaseFirestore

struct UserActivity: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let title: String
    let category: ActivityCategory
    let durationMinutes: Int
    let scheduledTime: Date
    let scheduledDate: Date
    let createdAt: Date
    private var _isOnHomeScreen: Bool?
    
    var isOnHomeScreen: Bool {
        get { _isOnHomeScreen ?? false }
        set { _isOnHomeScreen = newValue }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case title
        case category
        case durationMinutes
        case scheduledTime
        case scheduledDate
        case createdAt
        case _isOnHomeScreen = "isOnHomeScreen"
    }

    init(id: String? = nil, userId: String, title: String, category: ActivityCategory, durationMinutes: Int, scheduledTime: Date, scheduledDate: Date, createdAt: Date = Date(), isOnHomeScreen: Bool = false) {
        self.id = id
        self.userId = userId
        self.title = title
        self.category = category
        self.durationMinutes = durationMinutes
        self.scheduledTime = scheduledTime
        self.scheduledDate = scheduledDate
        self.createdAt = createdAt
        self._isOnHomeScreen = isOnHomeScreen
    }

    var displayDuration: String {
        let hours = durationMinutes / 60
        let minutes = durationMinutes % 60

        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }

    var displayTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: scheduledTime)
    }

    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: scheduledDate)
    }
}
