//
//  ProfileView.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var cartActivities: [Activity] = []
    @State private var cartUserActivities: [UserActivity] = []
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                contentView
            }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        HapticManager.impact(.light)
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.adaptiveWhite)
                    }
                }
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
            .overlay(
                Group {
                    if viewModel.showSuccessMessage {
                        ToastView(message: viewModel.successMessage, isShowing: .constant(true))
                            .animation(.spring(), value: viewModel.showSuccessMessage)
                    }
                }
            )
            .task {
                // Load cart item activities
                if let cart = viewModel.cart {
                    for cartItem in cart.items {
                        do {
                            if cartItem.isUserActivity {
                                if let userActivity = try await ActivityService.shared.getUserActivity(by: cartItem.activityId) {
                                    cartUserActivities.append(userActivity)
                                }
                            } else {
                                if let activity = try await ActivityService.shared.getActivity(by: cartItem.activityId) {
                                    cartActivities.append(activity)
                                }
                            }
                        } catch {
                            print("Error loading cart activity: \(error)")
                        }
                    }
                }
            }
            .onChange(of: viewModel.cart) { oldValue, newValue in
                // Reload cart activities when cart changes
                Task {
                    cartActivities.removeAll()
                    cartUserActivities.removeAll()
                    if let cart = newValue {
                        for cartItem in cart.items {
                            do {
                                if cartItem.isUserActivity {
                                    if let userActivity = try await ActivityService.shared.getUserActivity(by: cartItem.activityId) {
                                        cartUserActivities.append(userActivity)
                                    }
                                } else {
                                    if let activity = try await ActivityService.shared.getActivity(by: cartItem.activityId) {
                                        cartActivities.append(activity)
                                    }
                                }
                            } catch {
                                print("Error loading cart activity: \(error)")
                            }
                        }
                    }
                }
            }
            .onAppear {
                // Refresh profile, cart, and orders when navigating back
                Task {
                    await viewModel.refresh()
                }
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading && viewModel.user == nil {
            loadingView
        } else {
            mainContent
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .adaptiveWhite))
            .scaleEffect(1.5)
            .frame(maxWidth: .infinity)
            .padding(.top, 100)
    }
    
    private var mainContent: some View {
        VStack(spacing: 24) {
            profileHeaderSection

            cartSection
            orderHistorySection
        }
        .padding(.top, 16)
        .padding(.bottom, 100)
    }
    
    @ViewBuilder
    private var profileHeaderSection: some View {
        if let user = viewModel.user {
            ProfileHeader(user: user)
                .padding(.horizontal, 20)
        } else {
            EmptyStateView(
                icon: "person.crop.circle.badge.exclamationmark",
                title: "Profile Not Found",
                message: "Unable to load your profile. Please try again.",
                actionTitle: "Retry",
                action: {
                    Task {
                        await viewModel.refresh()
                    }
                }
            )
            .frame(height: 300)
        }
    }

    private var cartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Cart")
                .font(.h2)
                .foregroundColor(.adaptiveWhite)
                .padding(.horizontal, 20)
            
            if let cart = viewModel.cart, !cart.items.isEmpty {
                cartItemsList
                cartTotalAndOrder
            } else {
                emptyCartView
            }
        }
    }
    
    private var cartItemsList: some View {
        VStack(spacing: 12) {
            if let cart = viewModel.cart {
                ForEach(cart.items) { cartItem in
                    if cartItem.isUserActivity {
                        if let userActivity = cartUserActivities.first(where: { $0.id == cartItem.activityId }) {
                            CartUserActivityItemCard(
                                userActivity: userActivity,
                                onRemove: {
                                    Task {
                                        await viewModel.removeFromCart(cartItem.id)
                                    }
                                }
                            )
                        }
                    } else {
                        if let activity = cartActivities.first(where: { $0.id == cartItem.activityId }) {
                            CartItemCard(
                                activity: activity,
                                onRemove: {
                                    Task {
                                        await viewModel.removeFromCart(cartItem.id)
                                    }
                                }
                            )
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var cartTotalAndOrder: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Total:")
                    .font(.h3)
                    .foregroundColor(.adaptiveWhite)
                
                Spacer()
                
                Text("\(totalCartDuration) minutes")
                    .font(.h3)
                    .foregroundColor(.adaptiveWhite)
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 20)
            
            HStack(spacing: 12) {
                // Start Button
                Button(action: {
                    HapticManager.impact(.light)
                    // TODO: Add start functionality
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 16))
                        Text("Start")
                            .font(.bodyLarge)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.adaptiveWhite)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.green.opacity(0.6))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Stop Button
                Button(action: {
                    HapticManager.impact(.light)
                    // TODO: Add stop functionality
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 16))
                        Text("Stop")
                            .font(.bodyLarge)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.adaptiveWhite)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.red.opacity(0.6))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var emptyCartView: some View {
        EmptyStateView(
            icon: "cart.badge.questionmark",
            title: "Cart is Empty",
            message: "Add activities from the menu to get started!",
            actionTitle: nil,
            action: nil
        )
        .frame(height: 200)
        .padding(.horizontal, 20)
    }
    
    private var orderHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Order History")
                .font(.h2)
                .foregroundColor(.adaptiveWhite)
                .padding(.horizontal, 20)
            
            if viewModel.orders.isEmpty {
                emptyOrdersView
            } else {
                ordersList
            }
        }
        .padding(.top, 24)
    }
    
    private var emptyOrdersView: some View {
        EmptyStateView(
            icon: "clock.badge.questionmark",
            title: "No Orders Yet",
            message: "Your order history will appear here once you place your first order.",
            actionTitle: nil,
            action: nil
        )
        .frame(height: 200)
        .padding(.horizontal, 20)
    }
    
    private var ordersList: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.orders) { order in
                OrderCard(order: order)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var totalCartDuration: Int {
        let activityDuration = cartActivities.reduce(0) { $0 + $1.duration }
        let userActivityDuration = cartUserActivities.reduce(0) { $0 + $1.durationMinutes }
        return activityDuration + userActivityDuration
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

struct CartUserActivityItemCard: View {
    let userActivity: UserActivity
    let onRemove: () -> Void

    var body: some View {
        GlassCard(cornerRadius: 16) {
            HStack(spacing: 12) {
                // Icon badge for user activity
                Circle()
                    .fill(Color.purple.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.adaptiveWhite)
                    }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(userActivity.title)
                            .font(.h3)
                            .foregroundColor(.adaptiveWhite)
                        
                        // Badge to indicate it's a custom activity
                        Text("Custom")
                            .font(.system(size: 9))
                            .fontWeight(.semibold)
                            .foregroundColor(.adaptiveWhite)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.purple.opacity(0.6))
                            )
                    }

                    Label("\(userActivity.durationMinutes) min", systemImage: "clock.fill")
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

struct ProfileUserActivityCard: View {
    let userActivity: UserActivity
    let onAddToHome: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        GlassCard(cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text(userActivity.title)
                                .font(.h3)
                                .foregroundColor(.adaptiveWhite)
                            
                            if userActivity.isOnHomeScreen {
                                HStack(spacing: 4) {
                                    Image(systemName: "house.fill")
                                        .font(.system(size: 10))
                                    Text("On Home")
                                        .font(.system(size: 10))
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.adaptiveWhite)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(Color.green.opacity(0.6))
                                )
                            }
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
                        
                        HStack(spacing: 8) {
                            Label(userActivity.displayTime, systemImage: "clock")
                                .font(.caption)
                                .foregroundColor(.adaptiveSecondary)
                            
                            Text("•")
                                .foregroundColor(.adaptiveTertiary)
                            
                            Label(userActivity.displayDate, systemImage: "calendar")
                                .font(.caption)
                                .foregroundColor(.adaptiveSecondary)
                        }
                    }
                    
                    Spacer()
                }
                
                // Action buttons
                HStack(spacing: 12) {
                    if !userActivity.isOnHomeScreen {
                        Button(action: {
                            HapticManager.impact(.light)
                            onAddToHome()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "house.badge.plus")
                                    .font(.caption)
                                Text("Add to Home")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.adaptiveWhite)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.purple.opacity(0.6))
                            )
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        HapticManager.impact(.light)
                        onDelete()
                    }) {
                        Image(systemName: "trash.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(Color.red.opacity(0.2))
                            )
                    }
                }
            }
            .padding(16)
        }
    }
}

#Preview {
    ProfileView()
}
