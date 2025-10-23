//
//  HomeView.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showToast = false
    @State private var userName: String = ""
    @State private var currentStreak: Int = 0

    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.activities.isEmpty && viewModel.userActivities.isEmpty {
                    // Loading State
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .adaptiveWhite))
                        .scaleEffect(1.5)
                } else if viewModel.activities.isEmpty && viewModel.userActivities.isEmpty {
                    // Empty State
                    EmptyStateView(
                        icon: "tray",
                        title: "No Activities",
                        message: "No activities found. Please check your connection or try again later.",
                        actionTitle: "Retry",
                        action: {
                            Task {
                                await viewModel.refresh()
                            }
                        }
                    )
                } else {
                    VStack(spacing: 0) {
                        // Header
                        HomeHeader(
                            userName: userName,
                            streak: currentStreak
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                        // Activity List
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                // User Activities Section
                                if !viewModel.userActivities.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Your Activities")
                                            .font(.h3)
                                            .foregroundColor(.adaptiveWhite)
                                            .padding(.horizontal, 20)

                                        ForEach(viewModel.userActivities) { userActivity in
                                            UserActivityCard(
                                                userActivity: userActivity,
                                                onRemove: {
                                                    Task {
                                                        await viewModel.removeUserActivityFromHome(userActivity.id ?? "")
                                                    }
                                                }
                                            )
                                            .padding(.horizontal, 20)
                                        }
                                    }
                                    .padding(.top, 24)
                                }

                                // System Activities Section
                                if !viewModel.activities.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("Suggested Activities")
                                            .font(.h3)
                                            .foregroundColor(.adaptiveWhite)
                                            .padding(.horizontal, 20)
                                            .padding(.top, viewModel.userActivities.isEmpty ? 24 : 16)

                                        ForEach(viewModel.activities.prefix(5)) { activity in
                                            ActivityCard(
                                                activity: activity,
                                                isSelected: viewModel.isActivitySelected(activity.id),
                                                onToggle: {
                                                    viewModel.toggleActivitySelection(activity.id)
                                                }
                                            )
                                            .padding(.horizontal, 20)
                                            .transition(.asymmetric(
                                                insertion: .scale.combined(with: .opacity),
                                                removal: .scale.combined(with: .opacity)
                                            ))
                                        }
                                    }
                                }

                                // Explore More Button
                                NavigationLink {
                                    MenuView()
                                } label: {
                                    HStack {
                                        Text("Explore All Activities")
                                            .font(.bodyLarge)
                                            .fontWeight(.semibold)

                                        Image(systemName: "arrow.right")
                                    }
                                    .foregroundColor(.adaptiveWhite)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(.ultraThinMaterial)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(Color.borderLight, lineWidth: 1)
                                    )
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 24)
                            }
                            .padding(.bottom, 100)
                        }
                    }

                    // Add to Cart Button (Fixed at bottom)
                    if !viewModel.selectedActivities.isEmpty {
                        VStack {
                            Spacer()
                            GlassButton(
                                title: "Add to Cart (\(viewModel.selectedActivities.count))",
                                icon: "cart.badge.plus",
                                action: {
                                    Task {
                                        await viewModel.addSelectedToCart()
                                        showToast = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            showToast = false
                                        }
                                    }
                                }
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                ToastView(message: "Added to cart!", isShowing: $showToast)
                    .animation(.spring(), value: showToast)
            )
            .task {
                // Load user data
                if let userId = AuthService.shared.currentUser?.uid {
                    do {
                        let user = try await UserService.shared.fetchUserProfile(userId: userId)
                        userName = user.name
                        currentStreak = user.statistics.currentStreak
                    } catch {
                        print("Error loading user: \(error)")
                        userName = "User"
                        currentStreak = 0
                    }
                } else {
                    userName = "Guest"
                    currentStreak = 0
                }
            }
            .onAppear {
                // Refresh activities when navigating back to home screen
                Task {
                    await viewModel.refresh()
                }
            }
        }
    }
}

struct HomeHeader: View {
    let userName: String
    let streak: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back, \(userName)! 👋")
                        .font(.h2)
                        .foregroundColor(.adaptiveWhite)

                    if streak > 0 {
                        HStack(spacing: 6) {
                            Text("You have a \(streak) day streak")
                                .font(.bodySmall)
                                .foregroundColor(.adaptiveSecondary)

                            Text("🔥")
                        }
                    }
                }

                Spacer()

                // Notification and Profile
                HStack(spacing: 16) {
                    Button {
                        HapticManager.impact(.light)
                    } label: {
                        Image(systemName: "bell.fill")
                            .font(.title3)
                            .foregroundColor(.adaptiveWhite)
                    }

                    Circle()
                        .fill(Color.purple.opacity(0.3))
                        .frame(width: 36, height: 36)
                        .overlay {
                            Text(String(userName.prefix(1)))
                                .font(.bodySmall)
                                .fontWeight(.semibold)
                                .foregroundColor(.adaptiveWhite)
                        }
                }
            }
        }
    }
}

struct UserActivityCard: View {
    let userActivity: UserActivity
    let onRemove: () -> Void

    var body: some View {
        GlassCard(cornerRadius: 20) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(userActivity.title)
                            .font(.h3)
                            .foregroundColor(.adaptiveWhite)
                    }

                    HStack(spacing: 8) {
                        Label(userActivity.displayDuration, systemImage: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.adaptiveSecondary)

                        Text("•")
                            .foregroundColor(.adaptiveTertiary)

                        Text(userActivity.category.displayName)
                            .font(.caption)
                            .foregroundColor(.adaptiveSecondary)
                    }
                }

                Spacer()

                Button(action: {
                    HapticManager.impact(.light)
                    onRemove()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.adaptiveSecondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(16)
        }
    }
}

struct ActivityCard: View {
    let activity: Activity
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        GlassCard(cornerRadius: 20) {
            HStack(spacing: 16) {
                // Checkbox
                CustomCheckbox(isChecked: isSelected, onToggle: onToggle)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(activity.name)
                            .font(.h3)
                            .foregroundColor(.adaptiveWhite)

                        if let activityType = activity.activityType {
                            HStack(spacing: 4) {
                                Image(systemName: activityType.icon)
                                    .font(.system(size: 10))
                                Text(activityType.displayName)
                                    .font(.system(size: 10))
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.adaptiveWhite)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color.accentColor.opacity(0.6))
                            )
                        }
                    }

                    HStack(spacing: 8) {
                        Label("\(activity.duration) min", systemImage: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.adaptiveSecondary)

                        Text("•")
                            .foregroundColor(.adaptiveTertiary)

                        Text(activity.category.displayName)
                            .font(.caption)
                            .foregroundColor(.adaptiveSecondary)
                    }
                }

                Spacer()

                Text(activity.icon)
                    .font(.system(size: 32))
            }
            .padding(16)
        }
    }
}

struct ToastView: View {
    let message: String
    @Binding var isShowing: Bool

    var body: some View {
        VStack {
            if isShowing {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)

                    Text(message)
                        .font(.bodySmall)
                        .foregroundColor(.adaptiveWhite)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.borderLight, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.2), radius: 10)
                .padding(.top, 50)
            }

            Spacer()
        }
    }
}

#Preview {
    HomeView()
}
