//
//  TimerActivityAttributes.swift
//  Dopamine
//
//  ActivityAttributes for Live Activity timer countdown
//

import Foundation
import ActivityKit

struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic data that changes during the activity
        var remainingSeconds: Int
        var isPaused: Bool
        var lastUpdateTime: Date
    }

    // Static data that doesn't change
    var activityName: String
    var activityIcon: String
    var totalDurationMinutes: Int
    var activityId: String
}
