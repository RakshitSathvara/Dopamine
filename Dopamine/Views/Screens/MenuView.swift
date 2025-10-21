//
//  MenuView.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

struct MenuView: View {
    @State private var expandedCategories: Set<ActivityCategory> = [.starters]
    @State private var searchText = ""
    @Binding var cart: [Activity]
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var activities: [Activity] = Activity.sampleActivities
    @State private var showingAddActivity = false
    @State private var selectedCategory: ActivityCategory = .starters

    var filteredActivities: [Activity] {
        if searchText.isEmpty {
            return activities
        } else {
            return activities.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    func activities(for category: ActivityCategory) -> [Activity] {
        activities.filter { $0.category == category }
    }

    var body: some View {
        VStack(spacing: 0) {
                // Search Bar
                GlassTextField(
                    text: $searchText,
                    placeholder: "Search activities...",
                    icon: "magnifyingglass"
                )
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                // Categories List
                ScrollView {
                    LazyVStack(spacing: 20) {
                        if searchText.isEmpty {
                            ForEach(ActivityCategory.allCases, id: \.self) { category in
                                CategorySection(
                                    category: category,
                                    activities: activities(for: category),
                                    isExpanded: expandedCategories.contains(category),
                                    onToggle: {
                                        toggleCategory(category)
                                    },
                                    onAddToCart: { activity in
                                        addToCart(activity)
                                    },
                                    onAddActivity: {
                                        selectedCategory = category
                                        showingAddActivity = true
                                    },
                                    onRemoveActivity: { activity in
                                        removeActivity(activity)
                                    }
                                )
                            }
                        } else {
                            // Show filtered results
                            ForEach(filteredActivities) { activity in
                                MenuActivityCard(
                                    activity: activity,
                                    onAdd: {
                                        addToCart(activity)
                                    },
                                    onRemove: {
                                        removeActivity(activity)
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
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

    private func toggleCategory(_ category: ActivityCategory) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if expandedCategories.contains(category) {
                expandedCategories.remove(category)
            } else {
                expandedCategories.insert(category)
            }
        }
        HapticManager.impact(.light)
    }

    private func addToCart(_ activity: Activity) {
        HapticManager.notification(.success)
        cart.append(activity)
        toastMessage = "Added \(activity.name) to cart!"
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showToast = false
        }
    }

    private func addNewActivity(name: String, duration: Int, category: ActivityCategory, activityType: ActivityType?) {
        let newActivity = Activity(
            id: UUID().uuidString,
            name: name,
            description: "Custom activity",
            category: category,
            duration: duration,
            difficulty: .easy,
            benefits: ["Custom"],
            icon: "⭐",
            activityType: activityType
        )
        withAnimation {
            activities.append(newActivity)
        }
        HapticManager.notification(.success)
        toastMessage = "Added \(name) to \(category.displayName)!"
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showToast = false
        }
    }

    private func removeActivity(_ activity: Activity) {
        withAnimation {
            activities.removeAll { $0.id == activity.id }
        }
        HapticManager.impact(.medium)
        toastMessage = "Removed \(activity.name)"
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
        MenuView(cart: .constant([]))
    }
}
