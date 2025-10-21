//
//  HomeView.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

struct HomeView: View {
    @State private var activities: [Activity] = [
        Activity.sampleActivities[2], // Morning Meditation
        Activity.sampleActivities[3], // Deep Work Session
        Activity.sampleActivities[9]  // Evening Reading
    ]
    @State private var selectedActivities: Set<String> = []
    @State private var cart: [Activity] = []
    @State private var user = User.sample
    @State private var showToast = false

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // Header
                    HomeHeader(
                        userName: user.name,
                        streak: user.statistics.currentStreak
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    // Activity List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(Array(activities.enumerated()), id: \.element.id) { index, activity in
                                ActivityCard(
                                    activity: activity,
                                    isSelected: selectedActivities.contains(activity.id),
                                    onToggle: {
                                        toggleSelection(activity.id)
                                    }
                                )
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                            }

                            // Explore More Button
                            NavigationLink {
                                MenuView(cart: $cart)
                            } label: {
                                HStack {
                                    Text("Explore Menu")
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
                            .padding(.vertical, 24)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 100)
                    }
                }

                // Add to Cart Button (Fixed at bottom)
                if !selectedActivities.isEmpty {
                    VStack {
                        Spacer()
                        GlassButton(
                            title: "Add to Cart (\(selectedActivities.count))",
                            icon: "cart.badge.plus",
                            action: addToCart
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                ToastView(message: "Added to cart!", isShowing: $showToast)
                    .animation(.spring(), value: showToast)
            )
        }
    }

    private func toggleSelection(_ id: String) {
        HapticManager.impact(.light)
        withAnimation(.spring()) {
            if selectedActivities.contains(id) {
                selectedActivities.remove(id)
            } else {
                selectedActivities.insert(id)
            }
        }
    }

    private func addToCart() {
        HapticManager.notification(.success)
        let activitiesToAdd = activities.filter { selectedActivities.contains($0.id) }
        cart.append(contentsOf: activitiesToAdd)

        withAnimation(.spring()) {
            selectedActivities.removeAll()
        }

        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showToast = false
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
