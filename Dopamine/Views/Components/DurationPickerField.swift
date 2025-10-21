//
//  DurationPickerField.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

struct DurationPickerField: View {
    @Binding var durationMinutes: Int
    @State private var showingPicker = false
    @State private var selectedHours: Int = 0
    @State private var selectedMinutes: Int = 0

    let icon: String
    let placeholder: String

    var displayText: String {
        if durationMinutes > 0 {
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
        return ""
    }

    var body: some View {
        Button(action: {
            // Initialize picker values from current duration
            selectedHours = durationMinutes / 60
            selectedMinutes = durationMinutes % 60
            HapticManager.impact(.light)
            showingPicker = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.bodyLarge)
                    .foregroundColor(.adaptiveWhite.opacity(0.6))
                    .frame(width: 24)

                if displayText.isEmpty {
                    Text(placeholder)
                        .font(.bodyLarge)
                        .foregroundColor(.adaptiveWhite.opacity(0.4))
                } else {
                    Text(displayText)
                        .font(.bodyLarge)
                        .foregroundColor(.adaptiveWhite)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.adaptiveSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.borderLight, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingPicker) {
            DurationPickerSheet(
                hours: $selectedHours,
                minutes: $selectedMinutes,
                onSave: {
                    durationMinutes = (selectedHours * 60) + selectedMinutes
                    HapticManager.notification(.success)
                    showingPicker = false
                },
                onCancel: {
                    HapticManager.impact(.light)
                    showingPicker = false
                }
            )
            .presentationDetents([.height(400)])
            .presentationDragIndicator(.visible)
        }
    }
}

struct DurationPickerSheet: View {
    @Binding var hours: Int
    @Binding var minutes: Int
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Select Duration")
                    .font(.h2)
                    .foregroundColor(.adaptiveWhite)
                    .padding(.top, 20)

                HStack(spacing: 20) {
                    // Hours Picker
                    VStack(spacing: 8) {
                        Text("Hours")
                            .font(.caption)
                            .foregroundColor(.adaptiveSecondary)

                        Picker("Hours", selection: $hours) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text("\(hour)")
                                    .font(.h1)
                                    .foregroundColor(.adaptiveWhite)
                                    .tag(hour)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                    }

                    Text(":")
                        .font(.h1)
                        .foregroundColor(.adaptiveWhite)
                        .padding(.top, 20)

                    // Minutes Picker
                    VStack(spacing: 8) {
                        Text("Minutes")
                            .font(.caption)
                            .foregroundColor(.adaptiveSecondary)

                        Picker("Minutes", selection: $minutes) {
                            ForEach(0..<60, id: \.self) { minute in
                                Text("\(minute)")
                                    .font(.h1)
                                    .foregroundColor(.adaptiveWhite)
                                    .tag(minute)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                    }
                }
                .padding(.vertical, 20)

                Spacer()

                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: onSave) {
                        Text("Done")
                            .font(.h3)
                            .foregroundColor(.adaptiveWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.accentColor)
                            )
                    }
                    .disabled(hours == 0 && minutes == 0)
                    .opacity((hours == 0 && minutes == 0) ? 0.5 : 1.0)

                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.h3)
                            .foregroundColor(.adaptiveSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(.ultraThinMaterial)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.secondaryBackground)
        }
    }
}

#Preview {
    DurationPickerField(
        durationMinutes: .constant(45),
        icon: "clock.fill",
        placeholder: "Duration (minutes)"
    )
}
