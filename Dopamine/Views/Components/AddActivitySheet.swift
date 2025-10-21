//
//  AddActivitySheet.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

struct AddActivitySheet: View {
    @Environment(\.dismiss) var dismiss
    let category: ActivityCategory
    let onSave: (String, Int) -> Void

    @State private var activityName = ""
    @State private var durationMinutes = 0
    @FocusState private var focusedField: Field?

    enum Field {
        case name
    }

    var isValid: Bool {
        !activityName.isEmpty && durationMinutes > 0
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Category Display
                VStack(spacing: 8) {
                    Text("Adding to")
                        .font(.caption)
                        .foregroundColor(.adaptiveSecondary)

                    Text(category.displayName)
                        .font(.h1)
                        .foregroundColor(.adaptiveWhite)
                }
                .padding(.top, 20)

                // Form Fields
                VStack(spacing: 16) {
                    GlassTextField(
                        text: $activityName,
                        placeholder: "Activity name",
                        icon: "star.fill"
                    )
                    .focused($focusedField, equals: .name)

                    DurationPickerField(
                        durationMinutes: $durationMinutes,
                        icon: "clock.fill",
                        placeholder: "Duration"
                    )
                }
                .padding(.horizontal, 20)

                Spacer()

                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        if isValid {
                            onSave(activityName, durationMinutes)
                            HapticManager.notification(.success)
                            dismiss()
                        }
                    }) {
                        Text("Add Activity")
                            .font(.h3)
                            .foregroundColor(.adaptiveWhite)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(isValid ? Color.accentColor : Color.gray.opacity(0.3))
                            )
                    }
                    .disabled(!isValid)

                    Button(action: {
                        HapticManager.impact(.light)
                        dismiss()
                    }) {
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
            .navigationTitle("New Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            focusedField = .name
        }
    }
}

#Preview {
    AddActivitySheet(category: .starters, onSave: { _, _ in })
}
