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

    var filteredActivities: [Activity] {
        if searchText.isEmpty {
            return Activity.sampleActivities
        } else {
            return Activity.sampleActivities.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        ZStack {
            Color.Gradients.blue
                .ignoresSafeArea()

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
                                    activities: Activity.activities(for: category),
                                    isExpanded: expandedCategories.contains(category),
                                    onToggle: {
                                        toggleCategory(category)
                                    },
                                    onAddActivity: { activity in
                                        addActivity(activity)
                                    }
                                )
                            }
                        } else {
                            // Show filtered results
                            ForEach(filteredActivities) { activity in
                                MenuActivityCard(
                                    activity: activity,
                                    onAdd: {
                                        addActivity(activity)
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
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

    private func addActivity(_ activity: Activity) {
        HapticManager.notification(.success)
        cart.append(activity)
        toastMessage = "Added \(activity.name) to cart!"
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
    let onAddActivity: (Activity) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category Header
            Button(action: onToggle) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.bodySmall)
                        .foregroundColor(.white.opacity(0.8))

                    Text(category.displayName)
                        .font(.h2)
                        .foregroundColor(.white)

                    Spacer()

                    Text("\(activities.count)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
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
                                onAddActivity(activity)
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
    @State private var isAdded = false

    var body: some View {
        GlassCard(cornerRadius: 16) {
            HStack(spacing: 12) {
                // Icon
                Text(activity.icon)
                    .font(.system(size: 32))

                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.name)
                        .font(.h3)
                        .foregroundColor(.white)

                    HStack(spacing: 8) {
                        Label("\(activity.duration) min", systemImage: "clock.fill")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))

                        Text("•")
                            .foregroundColor(.white.opacity(0.6))

                        if let benefit = activity.benefits.first {
                            Text(benefit)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(1)
                        }
                    }
                }

                Spacer()

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
                        .foregroundColor(isAdded ? .green : .white)
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
