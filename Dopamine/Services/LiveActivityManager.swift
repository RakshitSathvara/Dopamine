//
//  LiveActivityManager.swift
//  Dopamine
//
//  Manager for handling Live Activities with countdown timers
//

import Foundation
import ActivityKit
import SwiftUI

@available(iOS 16.1, *)
class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()

    // Track active Live Activities by activity ID
    private var activities: [String: Activity<TimerActivityAttributes>] = [:]

    // Track timers for each activity
    private var timers: [String: Timer] = [:]

    private init() {}

    /// Start a Live Activity for a given activity
    func startActivity(activityId: String, name: String, icon: String, durationMinutes: Int) {
        // Stop any existing activity for this ID
        stopActivity(activityId: activityId)

        let attributes = TimerActivityAttributes(
            activityName: name,
            activityIcon: icon,
            totalDurationMinutes: durationMinutes,
            activityId: activityId
        )

        let contentState = TimerActivityAttributes.ContentState(
            remainingSeconds: durationMinutes * 60,
            isPaused: false,
            lastUpdateTime: Date()
        )

        do {
            let activity = try Activity<TimerActivityAttributes>.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )

            activities[activityId] = activity

            // Start a timer to update the Live Activity every second
            startTimer(activityId: activityId)

            print("✅ Live Activity started for: \(name)")
        } catch {
            print("❌ Failed to start Live Activity: \(error.localizedDescription)")
        }
    }

    /// Update the Live Activity state
    func updateActivity(activityId: String, remainingSeconds: Int, isPaused: Bool) {
        guard let activity = activities[activityId] else { return }

        let contentState = TimerActivityAttributes.ContentState(
            remainingSeconds: remainingSeconds,
            isPaused: isPaused,
            lastUpdateTime: Date()
        )

        Task {
            await activity.update(using: contentState)
        }
    }

    /// Pause the Live Activity timer
    func pauseActivity(activityId: String) {
        stopTimer(activityId: activityId)

        guard let activity = activities[activityId] else { return }

        Task {
            let currentState = await activity.contentState
            let contentState = TimerActivityAttributes.ContentState(
                remainingSeconds: currentState.remainingSeconds,
                isPaused: true,
                lastUpdateTime: Date()
            )
            await activity.update(using: contentState)
        }
    }

    /// Resume the Live Activity timer
    func resumeActivity(activityId: String) {
        guard let activity = activities[activityId] else { return }

        Task {
            let currentState = await activity.contentState
            let contentState = TimerActivityAttributes.ContentState(
                remainingSeconds: currentState.remainingSeconds,
                isPaused: false,
                lastUpdateTime: Date()
            )
            await activity.update(using: contentState)

            // Restart the timer
            startTimer(activityId: activityId)
        }
    }

    /// Stop and end the Live Activity
    func stopActivity(activityId: String) {
        stopTimer(activityId: activityId)

        guard let activity = activities[activityId] else { return }

        Task {
            await activity.end(dismissalPolicy: .immediate)
            activities.removeValue(forKey: activityId)
            print("✅ Live Activity ended for activity: \(activityId)")
        }
    }

    /// Complete the activity with a final state
    func completeActivity(activityId: String) {
        stopTimer(activityId: activityId)

        guard let activity = activities[activityId] else { return }

        let contentState = TimerActivityAttributes.ContentState(
            remainingSeconds: 0,
            isPaused: false,
            lastUpdateTime: Date()
        )

        Task {
            await activity.update(using: contentState)

            // Dismiss after 3 seconds
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            await activity.end(dismissalPolicy: .immediate)
            activities.removeValue(forKey: activityId)
            print("✅ Live Activity completed for activity: \(activityId)")
        }
    }

    /// Get current remaining seconds for an activity
    func getRemainingSeconds(activityId: String) async -> Int? {
        guard let activity = activities[activityId] else { return nil }
        let state = await activity.contentState
        return state.remainingSeconds
    }

    /// Check if activity is paused
    func isPaused(activityId: String) async -> Bool {
        guard let activity = activities[activityId] else { return false }
        let state = await activity.contentState
        return state.isPaused
    }

    // MARK: - Private Timer Management

    private func startTimer(activityId: String) {
        // Cancel any existing timer
        stopTimer(activityId: activityId)

        // Create a timer that fires every second
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timerTick(activityId: activityId)
        }

        timers[activityId] = timer
    }

    private func stopTimer(activityId: String) {
        timers[activityId]?.invalidate()
        timers.removeValue(forKey: activityId)
    }

    private func timerTick(activityId: String) {
        guard let activity = activities[activityId] else {
            stopTimer(activityId: activityId)
            return
        }

        Task {
            let currentState = await activity.contentState

            // Don't update if paused
            guard !currentState.isPaused else { return }

            let newRemainingSeconds = max(0, currentState.remainingSeconds - 1)

            // Update the Live Activity
            let contentState = TimerActivityAttributes.ContentState(
                remainingSeconds: newRemainingSeconds,
                isPaused: false,
                lastUpdateTime: Date()
            )

            await activity.update(using: contentState)

            // If timer reached 0, complete the activity
            if newRemainingSeconds == 0 {
                completeActivity(activityId: activityId)
            }
        }
    }

    /// Stop all active Live Activities
    func stopAllActivities() {
        for activityId in activities.keys {
            stopActivity(activityId: activityId)
        }
    }
}
