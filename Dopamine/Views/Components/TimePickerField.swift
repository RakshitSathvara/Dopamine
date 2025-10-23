//
//  TimePickerField.swift
//  Dopamine
//
//  Created by Rakshit on 23/10/25.
//

import SwiftUI

struct TimePickerField: View {
    @Binding var selectedTime: Date
    @State private var showingPicker = false

    let icon: String
    let label: String

    var displayText: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: selectedTime)
    }

    var body: some View {
        Button(action: {
            HapticManager.impact(.light)
            showingPicker = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.bodyLarge)
                    .foregroundColor(.adaptiveWhite.opacity(0.6))
                    .frame(width: 24)

                Text(label)
                    .font(.bodyLarge)
                    .foregroundColor(.adaptiveWhite.opacity(0.6))

                Spacer()

                Text(displayText)
                    .font(.bodyLarge)
                    .foregroundColor(.adaptiveWhite)

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
            TimePickerSheet(
                selectedTime: $selectedTime,
                onSave: {
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

struct TimePickerSheet: View {
    @Binding var selectedTime: Date
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Select Time")
                    .font(.h2)
                    .foregroundColor(.adaptiveWhite)
                    .padding(.top, 20)

                DatePicker(
                    "",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding(.horizontal, 20)

                Spacer()

                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: onSave) {
                        Text("Done")
                            .font(.h3)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.accentColor)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())

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
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color.secondaryBackground)
        }
    }
}

#Preview {
    TimePickerField(
        selectedTime: .constant(Date()),
        icon: "clock.fill",
        label: "Time"
    )
}
