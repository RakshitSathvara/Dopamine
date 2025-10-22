//
//  HomeViewModel.swift
//  Dopamine
//
//  ViewModel for the home screen
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var activities: [Activity] = []
    @Published var selectedActivities: Set<String> = []
    @Published var cartItemsCount = 0
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let activityService = ActivityService.shared
    private let orderService = OrderService.shared
    private let authService = AuthService.shared

    init() {
        Task {
            await loadActivities()
            await loadCart()
        }
    }

    // MARK: - Load Data

    func loadActivities() async {
        isLoading = true

        do {
            activities = try await activityService.fetchActivities()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Failed to load activities"
            print("Error loading activities: \(error.localizedDescription)")

            // Use sample data as fallback
            activities = Activity.sampleActivities
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

    // MARK: - Activity Selection

    func toggleActivitySelection(_ activityId: String) {
        if selectedActivities.contains(activityId) {
            selectedActivities.remove(activityId)
        } else {
            selectedActivities.insert(activityId)
        }
        HapticManager.impact(.light)
    }

    func isActivitySelected(_ activityId: String) -> Bool {
        selectedActivities.contains(activityId)
    }

    // MARK: - Add to Cart

    func addSelectedToCart() async {
        guard let userId = authService.currentUser?.uid else {
            errorMessage = "Please log in to add items to cart"
            return
        }

        guard !selectedActivities.isEmpty else {
            errorMessage = "Please select at least one activity"
            return
        }

        isLoading = true

        do {
            for activityId in selectedActivities {
                try await orderService.addToCart(userId: userId, activityId: activityId)
            }

            // Clear selections and reload cart
            selectedActivities.removeAll()
            await loadCart()

            isLoading = false
            HapticManager.notification(.success)
        } catch {
            isLoading = false
            errorMessage = "Failed to add items to cart"
            HapticManager.notification(.error)
            print("Error adding to cart: \(error.localizedDescription)")
        }
    }

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

    // MARK: - Categories

    func activities(for category: ActivityCategory) -> [Activity] {
        activities.filter { $0.category == category }
    }

    // MARK: - Refresh

    func refresh() async {
        await loadActivities()
        await loadCart()
    }
}
