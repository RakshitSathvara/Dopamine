//
//  DopamineTimerLiveActivity.swift
//  DopamineTimerWidget
//
//  Live Activity Widget for displaying countdown timer
//

import ActivityKit
import WidgetKit
import SwiftUI

struct DopamineTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock screen/banner UI
            LiveActivityView(context: context)
                .activityBackgroundTint(Color.black.opacity(0.8))
                .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        Text(context.attributes.activityIcon)
                            .font(.system(size: 32))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.activityName)
                                .font(.caption)
                                .fontWeight(.semibold)
                            Text("Activity Timer")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(timeString(from: context.state.remainingSeconds))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .monospacedDigit()

                        if context.state.isPaused {
                            Text("PAUSED")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 8) {
                        ProgressView(value: progressValue(remaining: context.state.remainingSeconds, total: context.attributes.totalDurationMinutes * 60))
                            .progressViewStyle(.linear)
                            .tint(.green)

                        HStack {
                            Text("Time Remaining")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(context.state.remainingSeconds / 60)m left")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } compactLeading: {
                // Compact Leading (left side of Dynamic Island)
                Text(context.attributes.activityIcon)
                    .font(.system(size: 20))
            } compactTrailing: {
                // Compact Trailing (right side of Dynamic Island)
                Text(timeString(from: context.state.remainingSeconds))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .monospacedDigit()
            } minimal: {
                // Minimal view
                Text(context.attributes.activityIcon)
                    .font(.system(size: 16))
            }
        }
    }

    // MARK: - Helper Views and Functions

    private func timeString(from seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }

    private func progressValue(remaining: Int, total: Int) -> Double {
        guard total > 0 else { return 0 }
        return Double(total - remaining) / Double(total)
    }
}

// MARK: - Live Activity View (Lock Screen)

struct LiveActivityView: View {
    let context: ActivityViewContext<TimerActivityAttributes>

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Icon
                Text(context.attributes.activityIcon)
                    .font(.system(size: 40))

                VStack(alignment: .leading, spacing: 4) {
                    Text(context.attributes.activityName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("Dopamine Activity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Timer Display
                VStack(alignment: .trailing, spacing: 2) {
                    Text(timeString(from: context.state.remainingSeconds))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .monospacedDigit()

                    if context.state.isPaused {
                        Text("PAUSED")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    } else {
                        Text("remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Progress Bar
            VStack(spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 8)

                        // Progress
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [.green, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progressValue(remaining: context.state.remainingSeconds, total: context.attributes.totalDurationMinutes * 60), height: 8)
                    }
                }
                .frame(height: 8)

                HStack {
                    Text("Started")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(context.state.remainingSeconds / 60) min left")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
    }

    private func timeString(from seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%d:%02d", minutes, secs)
        }
    }

    private func progressValue(remaining: Int, total: Int) -> Double {
        guard total > 0 else { return 0 }
        return Double(total - remaining) / Double(total)
    }
}
