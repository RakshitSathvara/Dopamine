//
//  MenuViewModel.swift
//  Dopamine
//
//  ViewModel for the menu/activities browser screen
//

import Foundation
import SwiftUI
internal import Combine
import FirebaseAuth

@MainActor
class MenuViewModel: ObservableObject {
    @Published var activities: [Activity] = []
    @Published var activitiesByCategory: [ActivityCategory: [Activity]] = [:]
    @Published var expandedCategories: Set<ActivityCategory> = Set(ActivityCategory.allCases)
    @Published var searchQuery = ""
    @Published var selectedDifficulty: Difficulty?
    @Published var cartItemsCount = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var menuConfiguration: MenuConfiguration?

    private let activityService = ActivityService.shared
    private let orderService = OrderService.shared
    private let authService = AuthService.shared
    private let menuService = MenuService.shared

    init() {
        Task {
            await loadMenuConfiguration()
            await loadActivities()
            await loadCart()
        }
    }

    // MARK: - Load Data

    func loadMenuConfiguration() async {
        do {
            menuConfiguration = try await menuService.fetchMenuConfiguration()
        } catch {
            print("Error loading menu configuration: \(error.localizedDescription)")
            // Fallback to default configuration
            menuConfiguration = MenuConfiguration.default
        }
    }

    func loadActivities() async {
        isLoading = true

        do {
            activities = try await activityService.fetchActivities()
            organizeActivitiesByCategory()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load activities"
            print("Error loading activities: \(error.localizedDescription)")

            // Use sample data as fallback
            activities = Activity.sampleActivities
            organizeActivitiesByCategory()
        }
    }

    func loadCart() async {
        guard let userId = authService.currentUser?.uid else { return }

        do {
            let cart = try await orderService.fetchCart(userId: userId)
            cartItemsCount = cart.items.count
        } catch {
            print("Error loading cart: \(error.localizedDescription)")
        }
    }

    // MARK: - Category Management

    func toggleCategory(_ category: ActivityCategory) {
        if expandedCategories.contains(category) {
            expandedCategories.remove(category)
        } else {
            expandedCategories.insert(category)
        }
        HapticManager.impact(.light)
    }

    func isCategoryExpanded(_ category: ActivityCategory) -> Bool {
        expandedCategories.contains(category)
    }

    // MARK: - Add to Cart

    func addToCart(_ activityId: String) async {
        guard let userId = authService.currentUser?.uid else {
            errorMessage = "Please log in to add items to cart"
            return
        }

        do {
            try await orderService.addToCart(userId: userId, activityId: activityId)
            await loadCart()
            HapticManager.notification(.success)
        } catch {
            errorMessage = "Failed to add item to cart"
            HapticManager.notification(.error)
            print("Error adding to cart: \(error.localizedDescription)")
        }
    }

    // MARK: - Search & Filter

    var filteredActivities: [Activity] {
        var filtered = activities

        // Apply search query
        if !searchQuery.isEmpty {
            filtered = activityService.searchActivities(query: searchQuery)
        }

        // Apply difficulty filter
        if let difficulty = selectedDifficulty {
            filtered = filtered.filter { $0.difficulty == difficulty }
        }

        return filtered
    }

    func activitiesForCategory(_ category: ActivityCategory) -> [Activity] {
        let categoryActivities = activitiesByCategory[category] ?? []

        // Apply filters
        var filtered = categoryActivities

        if !searchQuery.isEmpty {
            filtered = filtered.filter { activity in
                activity.name.localizedCaseInsensitiveContains(searchQuery) ||
                activity.description.localizedCaseInsensitiveContains(searchQuery)
            }
        }

        if let difficulty = selectedDifficulty {
            filtered = filtered.filter { $0.difficulty == difficulty }
        }

        return filtered
    }

    // MARK: - Helper Methods

    private func organizeActivitiesByCategory() {
        activitiesByCategory = Dictionary(grouping: activities, by: { $0.category })
    }

    func clearFilters() {
        searchQuery = ""
        selectedDifficulty = nil
    }

    func refresh() async {
        await loadMenuConfiguration()
        await loadActivities()
        await loadCart()
    }

    // MARK: - Menu Configuration

    func getCategoryInfo(for category: ActivityCategory) -> MenuCategoryInfo {
        return menuConfiguration?.getCategoryInfo(for: category) ?? MenuConfiguration.default.getCategoryInfo(for: category)
    }

    func getCategoryTitle(for category: ActivityCategory) -> String {
        return getCategoryInfo(for: category).title
    }

    func getCategoryDescription(for category: ActivityCategory) -> String {
        return getCategoryInfo(for: category).description
    }

    func getCategoryIcon(for category: ActivityCategory) -> String {
        return getCategoryInfo(for: category).icon
    }
}
