//
//  MenuView.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI
import FirebaseFirestore

struct MenuView: View {
    @StateObject private var viewModel = MenuViewModel()
    @State private var showToast = false
    @State private var toastMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading && viewModel.menuConfiguration == nil {
                // Loading State
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .adaptiveWhite))
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let menuConfig = viewModel.menuConfiguration {
                // Menu Categories List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(menuConfig.getAllCategories(), id: \.category) { item in
                            MenuCategoryCard(
                                categoryInfo: item.info,
                                category: item.category,
                                onAdd: {
                                    handleAddCategory(item.category, item.info)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            } else {
                // Error State
                EmptyStateView(
                    icon: "exclamationmark.triangle",
                    title: "Menu Not Available",
                    message: "Unable to load menu. Please try again later.",
                    actionTitle: "Retry",
                    action: {
                        Task {
                            await viewModel.refresh()
                        }
                    }
                )
            }
        }
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .overlay(
            ToastView(message: toastMessage, isShowing: $showToast)
                .animation(.spring(), value: showToast)
        )
    }

    private func handleAddCategory(_ category: ActivityCategory, _ info: MenuCategoryInfo) {
        toastMessage = "Added \(info.title) to your selections!"
        showToast = true
        HapticManager.notification(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showToast = false
        }
    }
}

// MARK: - Menu Category Card
struct MenuCategoryCard: View {
    let categoryInfo: MenuCategoryInfo
    let category: ActivityCategory
    let onAdd: () -> Void
    @State private var isAdded = false
    @State private var showBottomSheet = false
    @State private var userActivities: [UserActivity] = []
    @StateObject private var authService = AuthService.shared
    @State private var listener: ListenerRegistration?

    var body: some View {
        GlassCard(cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 12) {
                // Top: Icon, Title, and Add Button in same line
                HStack(alignment: .center, spacing: 10) {
                    // Category Icon
                    Text(categoryInfo.icon)
                        .font(.system(size: 16))
                        .frame(width: 26, height: 26)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )

                    // Category Name
                    Text(categoryInfo.title)
                        .font(.headline)
                        .foregroundColor(.adaptiveWhite)

                    Spacer()

                    // Add Item Button
                    Button(action: {
                        HapticManager.impact(.light)
                        showBottomSheet = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 12, weight: .bold))
                            Text("Add Item")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.adaptiveWhite)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                        )
                    }
                }

                // Category Description
                Text(categoryInfo.description)
                    .font(.caption2)
                    .foregroundColor(.adaptiveSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                // User Activities List
                if !userActivities.isEmpty {
                    Divider()
                        .background(Color.adaptiveWhite.opacity(0.2))
                        .padding(.vertical, 4)

                    VStack(spacing: 0) {
                        ForEach(Array(userActivities.prefix(3).enumerated()), id: \.element.id) { index, activity in
                            UserActivityRow(activity: activity)
                                .padding(.vertical, 8)

                            if index < min(userActivities.count, 3) - 1 {
                                Divider()
                                    .background(Color.adaptiveWhite.opacity(0.1))
                            }
                        }

                        if userActivities.count > 3 {
                            Divider()
                                .background(Color.adaptiveWhite.opacity(0.1))
                                .padding(.bottom, 4)

                            Text("+\(userActivities.count - 3) more")
                                .font(.caption)
                                .foregroundColor(.adaptiveSecondary)
                                .padding(.top, 4)
                        }
                    }
                }
            }
            .padding(16)
        }
        .sheet(isPresented: $showBottomSheet) {
            CategoryBottomSheet(
                categoryInfo: categoryInfo,
                category: category,
                onAdd: {
                    onAdd()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isAdded = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isAdded = false
                        }
                    }
                }
            )
            .environmentObject(authService)
        }
        .onAppear {
            setupListener()
        }
        .onDisappear {
            listener?.remove()
        }
    }

    private func setupListener() {
        guard let userId = authService.currentUser?.uid else { return }

        listener = ActivityService.shared.listenToUserActivitiesByCategory(
            userId: userId,
            category: category
        ) { activities in
            DispatchQueue.main.async {
                self.userActivities = activities
            }
        }
    }
}

// MARK: - User Activity Row
struct UserActivityRow: View {
    let activity: UserActivity
    @State private var showDeleteAlert = false

    var body: some View {
        HStack(spacing: 8) {
            // Title and Duration
            HStack(alignment: .top, spacing: 6) {
                Text(activity.title)
                    .font(.caption)
                    .foregroundColor(.adaptiveWhite)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text("•")
                    .font(.caption)
                    .foregroundColor(.adaptiveSecondary)

                Text(activity.displayDuration)
                    .font(.caption)
                    .foregroundColor(.adaptiveSecondary)
            }

            Spacer()

            // Action Icons
            HStack(spacing: 12) {
                // Add Icon
                Button(action: {
                    HapticManager.impact(.light)
                    // Handle add action
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())

                // Delete Icon
                Button(action: {
                    HapticManager.impact(.light)
                    showDeleteAlert = true
                }) {
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.red.opacity(0.8))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .alert("Delete Activity", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteActivity()
            }
        } message: {
            Text("Are you sure you want to delete '\(activity.title)'?")
        }
    }

    private func deleteActivity() {
        Task {
            do {
                try await ActivityService.shared.deleteUserActivity(activityId: activity.id)
                HapticManager.notification(.success)
            } catch {
                print("Error deleting activity: \(error.localizedDescription)")
                HapticManager.notification(.error)
            }
        }
    }
}

// MARK: - Category Bottom Sheet
struct CategoryBottomSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authService: AuthService
    let categoryInfo: MenuCategoryInfo
    let category: ActivityCategory
    let onAdd: () -> Void

    @State private var title = ""
    @State private var durationMinutes = 0
    @State private var selectedTime = Date()
    @State private var selectedDate = Date()
    @State private var isSubmitting = false
    @FocusState private var focusedField: Field?

    enum Field {
        case title
    }

    var isValid: Bool {
        !title.isEmpty && durationMinutes > 0
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Category Icon and Title
                    VStack(spacing: 12) {
                        Text(categoryInfo.icon)
                            .font(.system(size: 64))
                            .frame(width: 80, height: 80)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                            )

                        Text(categoryInfo.title)
                            .font(.h1)
                            .foregroundColor(.adaptiveWhite)
                    }
                    .padding(.top, 20)

                    // Description
                    Text(categoryInfo.description)
                        .font(.bodyRegular)
                        .foregroundColor(.adaptiveSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    // Form Fields
                    VStack(spacing: 16) {
                        // Title Field
                        GlassTextField(
                            text: $title,
                            placeholder: "Activity title",
                            icon: "text.bubble.fill"
                        )
                        .focused($focusedField, equals: .title)

                        // Duration Field
                        DurationPickerField(
                            durationMinutes: $durationMinutes,
                            icon: "clock.fill",
                            placeholder: "Duration"
                        )

                        // Time Picker
                        TimePickerField(
                            selectedTime: $selectedTime,
                            icon: "clock.fill",
                            label: "Time"
                        )

                        // Date Picker
                        DatePickerField(
                            selectedDate: $selectedDate,
                            icon: "calendar",
                            label: "Date"
                        )
                    }
                    .padding(.horizontal, 20)

                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            Task {
                                await submitActivity()
                            }
                        }) {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Submit")
                                    .font(.h3)
                                    .foregroundColor(isValid ? .white : .adaptiveSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(isValid ? Color.accentColor : Color.gray.opacity(0.3))
                        )
                        .disabled(!isValid || isSubmitting)
                        .buttonStyle(PlainButtonStyle())

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
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(Color.secondaryBackground)
            .navigationTitle(category.displayName)
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
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private func submitActivity() async {
        guard let userId = authService.currentUser?.uid else {
            print("Error: No user logged in")
            return
        }

        isSubmitting = true

        do {
            try await ActivityService.shared.createUserActivity(
                userId: userId,
                title: title,
                category: category,
                durationMinutes: durationMinutes,
                scheduledTime: selectedTime,
                scheduledDate: selectedDate
            )

            HapticManager.notification(.success)
            onAdd()
            dismiss()
        } catch {
            print("Error creating activity: \(error.localizedDescription)")
            HapticManager.notification(.error)
        }

        isSubmitting = false
    }
}

#Preview {
    NavigationStack {
        MenuView()
    }
}
