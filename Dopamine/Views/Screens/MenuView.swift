//
//  MenuView.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

struct MenuView: View {
    @StateObject private var viewModel = MenuViewModel()
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var showingAddActivity = false
    @State private var selectedCategory: ActivityCategory = .starters

    var filteredActivities: [Activity] {
        viewModel.filteredActivities
    }

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading && viewModel.activities.isEmpty {
                // Loading State
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .adaptiveWhite))
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.activities.isEmpty {
                // Empty State
                EmptyStateView(
                    icon: "list.bullet.rectangle",
                    title: "No Activities Available",
                    message: "There are no activities to display. Please check your connection or try again later.",
                    actionTitle: "Retry",
                    action: {
                        Task {
                            await viewModel.refresh()
                        }
                    }
                )
            } else {
                VStack(spacing: 0) {
                    // Search Bar
                    GlassTextField(
                        text: $viewModel.searchQuery,
                        placeholder: "Search activities...",
                        icon: "magnifyingglass"
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)

                    // Categories List
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            if viewModel.searchQuery.isEmpty {
                                ForEach(ActivityCategory.allCases, id: \.self) { category in
                                    let categoryActivities = viewModel.activitiesForCategory(category)
                                    if !categoryActivities.isEmpty {
                                        CategorySection(
                                            category: category,
                                            activities: categoryActivities,
                                            isExpanded: viewModel.isCategoryExpanded(category),
                                            onToggle: {
                                                viewModel.toggleCategory(category)
                                            },
                                            onAddToCart: { activity in
                                                Task {
                                                    await addToCart(activity)
                                                }
                                            },
                                            onAddActivity: {
                                                selectedCategory = category
                                                showingAddActivity = true
                                            },
                                            onRemoveActivity: { activity in
                                                // Remove functionality - would need Firebase implementation
                                                toastMessage = "Activity management coming soon"
                                                showToast = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                    showToast = false
                                                }
                                            }
                                        )
                                    }
                                }
                            } else {
                                // Show filtered results
                                if filteredActivities.isEmpty {
                                    EmptyStateView(
                                        icon: "magnifyingglass",
                                        title: "No Results",
                                        message: "No activities found matching '\(viewModel.searchQuery)'. Try a different search.",
                                        actionTitle: nil,
                                        action: nil
                                    )
                                    .frame(height: 400)
                                } else {
                                    ForEach(filteredActivities) { activity in
                                        MenuActivityCard(
                                            activity: activity,
                                            onAdd: {
                                                Task {
                                                    await addToCart(activity)
                                                }
                                            },
                                            onRemove: {
                                                // Remove functionality - would need Firebase implementation
                                                toastMessage = "Activity management coming soon"
                                                showToast = true
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                    showToast = false
                                                }
                                            }
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .navigationTitle("Browse Activities")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .overlay(
            ToastView(message: toastMessage, isShowing: $showToast)
                .animation(.spring(), value: showToast)
        )
        .sheet(isPresented: $showingAddActivity) {
            AddActivitySheet(
                category: selectedCategory,
                onSave: { name, duration, activityType in
                    addNewActivity(name: name, duration: duration, category: selectedCategory, activityType: activityType)
                }
            )
        }
    }

    private func addToCart(_ activity: Activity) async {
        await viewModel.addToCart(activity.id)
        toastMessage = "Added \(activity.name) to cart!"
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showToast = false
        }
    }

    private func addNewActivity(name: String, duration: Int, category: ActivityCategory, activityType: ActivityType?) {
        // This would need to be implemented in Firebase
        toastMessage = "Custom activity creation coming soon!"
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showToast = false
        }
    }
}

struct CategorySection: View {
    let category: ActivityCategory
    let activities: [Activity]
    let isExpanded: Bool
    let onToggle: () -> Void
    let onAddToCart: (Activity) -> Void
    let onAddActivity: () -> Void
    let onRemoveActivity: (Activity) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category Header
            HStack {
                Button(action: onToggle) {
                    HStack(spacing: 8) {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.bodySmall)
                            .foregroundColor(.adaptiveSecondary)

                        Text(category.displayName)
                            .font(.h2)
                            .foregroundColor(.adaptiveWhite)
                    }
                }

                Spacer()

                Text("\(activities.count)")
                    .font(.caption)
                    .foregroundColor(.adaptiveSecondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )

                // Plus Button
                Button(action: onAddActivity) {
                    Image(systemName: "plus")
                        .font(.bodyLarge)
                        .fontWeight(.semibold)
                        .foregroundColor(.adaptiveWhite)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }
            }

            // Activities
            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(activities) { activity in
                        MenuActivityCard(
                            activity: activity,
                            onAdd: {
                                onAddToCart(activity)
                            },
                            onRemove: {
                                onRemoveActivity(activity)
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                    }
                }
            }
        }
    }
}

struct MenuActivityCard: View {
    let activity: Activity
    let onAdd: () -> Void
    let onRemove: () -> Void
    @State private var isAdded = false

    var body: some View {
        GlassCard(cornerRadius: 16) {
            HStack(spacing: 12) {
                // Icon
                Text(activity.icon)
                    .font(.system(size: 32))

                VStack(alignment: .leading, spacing: 4) {
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

                        if let benefit = activity.benefits.first {
                            Text(benefit)
                                .font(.caption)
                                .foregroundColor(.adaptiveSecondary)
                                .lineLimit(1)
                        }
                    }
                }

                Spacer()

                // Remove Button
                Button(action: onRemove) {
                    Image(systemName: "trash")
                        .font(.bodySmall)
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }

                // Add Button
                Button(action: {
                    onAdd()
                    withAnimation(.spring()) {
                        isAdded = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.spring()) {
                            isAdded = false
                        }
                    }
                }) {
                    Image(systemName: isAdded ? "checkmark" : "plus")
                        .font(.bodyLarge)
                        .fontWeight(.semibold)
                        .foregroundColor(isAdded ? .green : .adaptiveWhite)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }
                .disabled(isAdded)
            }
            .padding(12)
        }
    }
}

#Preview {
    NavigationStack {
        MenuView()
    }
}
