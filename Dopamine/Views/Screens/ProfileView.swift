//
//  ProfileView.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var user = User.sample
    @State private var cartItems: [Activity] = [
        Activity.sampleActivities[2], // Morning Meditation
        Activity.sampleActivities[3]  // Deep Work Session
    ]
    @State private var orders = Order.sampleOrders
    @State private var showToast = false
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showThemeSelector = false

    var totalDuration: Int {
        cartItems.reduce(0) { $0 + $1.duration }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        ProfileHeader(user: user)
                            .padding(.horizontal, 20)

                        // Theme Selector
                        ThemeSelectorCard(
                            currentTheme: $themeManager.currentTheme,
                            showThemeSelector: $showThemeSelector
                        )
                        .padding(.horizontal, 20)

                        // Cart Section
                        if !cartItems.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Your Cart")
                                    .font(.h2)
                                    .foregroundColor(.adaptiveWhite)
                                    .padding(.horizontal, 20)

                                VStack(spacing: 12) {
                                    ForEach(cartItems) { activity in
                                        CartItemCard(
                                            activity: activity,
                                            onRemove: {
                                                removeFromCart(activity)
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)

                                // Total and Place Order
                                VStack(spacing: 12) {
                                    HStack {
                                        Text("Total:")
                                            .font(.h3)
                                            .foregroundColor(.adaptiveWhite)

                                        Spacer()

                                        Text("\(totalDuration) minutes")
                                            .font(.h3)
                                            .foregroundColor(.adaptiveWhite)
                                            .fontWeight(.bold)
                                    }
                                    .padding(.horizontal, 20)

                                    GlassButton(
                                        title: "Place Order",
                                        icon: "checkmark.circle.fill",
                                        action: placeOrder
                                    )
                                    .padding(.horizontal, 20)
                                }
                            }
                        }

                        // Order History
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Order History")
                                .font(.h2)
                                .foregroundColor(.adaptiveWhite)
                                .padding(.horizontal, 20)

                            VStack(spacing: 12) {
                                ForEach(orders) { order in
                                    OrderCard(order: order)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 24)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 100)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.impact(.light)
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.adaptiveWhite)
                    }
                }
            }
            .overlay(
                ToastView(message: "Order placed successfully!", isShowing: $showToast)
                    .animation(.spring(), value: showToast)
            )
        }
    }

    private func removeFromCart(_ activity: Activity) {
        HapticManager.impact(.medium)
        withAnimation(.spring()) {
            cartItems.removeAll { $0.id == activity.id }
        }
    }

    private func placeOrder() {
        HapticManager.notification(.success)

        // Create new order from cart items
        let newOrder = Order(
            id: UUID().uuidString,
            userId: user.id,
            items: cartItems.map { activity in
                OrderItem(
                    id: UUID().uuidString,
                    activityId: activity.id,
                    activityName: activity.name,
                    duration: activity.duration,
                    isCompleted: false,
                    completedAt: nil
                )
            },
            status: .active,
            createdAt: Date(),
            completedAt: nil
        )

        withAnimation(.spring()) {
            orders.insert(newOrder, at: 0)
            cartItems.removeAll()
        }

        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showToast = false
        }
    }
}

struct ProfileHeader: View {
    let user: User

    var body: some View {
        GlassCard(cornerRadius: 20) {
            VStack(spacing: 16) {
                // Avatar
                Circle()
                    .fill(Color.purple.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay {
                        Text(String(user.name.prefix(1)))
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.adaptiveWhite)
                    }

                // User Info
                VStack(spacing: 4) {
                    Text(user.name)
                        .font(.h2)
                        .foregroundColor(.adaptiveWhite)

                    Text(user.email)
                        .font(.bodySmall)
                        .foregroundColor(.adaptiveSecondary)
                }

                // Streak
                HStack(spacing: 8) {
                    Text("🔥")
                        .font(.title2)

                    Text("\(user.statistics.currentStreak) day streak!")
                        .font(.h3)
                        .foregroundColor(.adaptiveWhite)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                )

                // Stats
                HStack(spacing: 20) {
                    StatItem(
                        value: "\(user.statistics.totalActivitiesCompleted)",
                        label: "Completed"
                    )

                    Divider()
                        .frame(height: 40)
                        .background(Color.white.opacity(0.3))

                    StatItem(
                        value: "\(user.statistics.totalMinutes)",
                        label: "Minutes"
                    )

                    Divider()
                        .frame(height: 40)
                        .background(Color.white.opacity(0.3))

                    StatItem(
                        value: "\(user.statistics.longestStreak)",
                        label: "Best Streak"
                    )
                }
            }
            .padding(20)
        }
    }
}

struct StatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.h2)
                .foregroundColor(.adaptiveWhite)

            Text(label)
                .font(.caption)
                .foregroundColor(.adaptiveSecondary)
        }
    }
}

struct CartItemCard: View {
    let activity: Activity
    let onRemove: () -> Void

    var body: some View {
        GlassCard(cornerRadius: 16) {
            HStack(spacing: 12) {
                Text(activity.icon)
                    .font(.system(size: 28))

                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.name)
                        .font(.h3)
                        .foregroundColor(.adaptiveWhite)

                    Label("\(activity.duration) min", systemImage: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.adaptiveSecondary)
                }

                Spacer()

                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.adaptiveTertiary)
                }
            }
            .padding(12)
        }
    }
}

struct OrderCard: View {
    let order: Order

    var body: some View {
        GlassCard(cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(order.status == .completed ? "Completed Activities" : "Active Order")
                            .font(.h3)
                            .foregroundColor(.adaptiveWhite)

                        Text("\(order.completedItemsCount) of \(order.items.count) completed • \(order.createdAt.formatShort())")
                            .font(.caption)
                            .foregroundColor(.adaptiveSecondary)
                    }

                    Spacer()

                    if order.status == .completed {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }

                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.green)
                            .frame(
                                width: geometry.size.width * (order.completionPercentage / 100),
                                height: 6
                            )
                    }
                }
                .frame(height: 6)

                // Activities List
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(order.items.prefix(3)) { item in
                        HStack {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.isCompleted ? .green : .adaptiveTertiary)

                            Text(item.activityName)
                                .font(.bodySmall)
                                .foregroundColor(.adaptiveWhite)

                            Spacer()

                            Text("\(item.duration) min")
                                .font(.caption)
                                .foregroundColor(.adaptiveSecondary)
                        }
                    }

                    if order.items.count > 3 {
                        Text("+ \(order.items.count - 3) more")
                            .font(.caption)
                            .foregroundColor(.adaptiveTertiary)
                    }
                }
            }
            .padding(16)
        }
    }
}

struct ThemeSelectorCard: View {
    @Binding var currentTheme: AppTheme
    @Binding var showThemeSelector: Bool

    var body: some View {
        GlassCard(cornerRadius: 16) {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "paintbrush.fill")
                        .foregroundColor(.adaptiveWhite)

                    Text("Theme")
                        .font(.h3)
                        .foregroundColor(.adaptiveWhite)

                    Spacer()
                }

                HStack(spacing: 12) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        ThemeOptionButton(
                            theme: theme,
                            isSelected: currentTheme == theme,
                            action: {
                                ThemeManager.shared.setTheme(theme)
                            }
                        )
                    }
                }
            }
            .padding(16)
        }
    }
}

struct ThemeOptionButton: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: theme.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .purple : .adaptiveSecondary)

                Text(theme.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .purple : .adaptiveSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color.purple.opacity(0.2) : .clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? Color.purple : Color.borderLight, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

#Preview {
    ProfileView()
}
