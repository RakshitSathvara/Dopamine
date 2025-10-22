//
//  ProfileViewModel.swift
//  Dopamine
//
//  ViewModel for the profile screen with cart and order management
//

import Foundation
import SwiftUI
internal import Combine
import FirebaseAuth

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var cart: Cart?
    @Published var orders: [Order] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccessMessage = false
    @Published var successMessage = ""

    private let userService = UserService.shared
    private let orderService = OrderService.shared
    private let authService = AuthService.shared

    init() {
        Task {
            await loadUserProfile()
            await loadCart()
            await loadOrders()
        }
    }

    // MARK: - Load Data

    func loadUserProfile() async {
        guard let userId = authService.currentUser?.uid else { return }

        isLoading = true

        do {
            user = try await userService.fetchUserProfile(userId: userId)
            isLoading = false
        } catch {
            isLoading = false
            print("Error loading user profile: \(error.localizedDescription)")

            // Try to create profile if it doesn't exist
            if let email = authService.currentUser?.email {
                do {
                    try await userService.createUserProfile(userId: userId, email: email)
                    user = try await userService.fetchUserProfile(userId: userId)
                } catch {
                    errorMessage = "Failed to load profile"
                }
            }
        }
    }

    func loadCart() async {
        guard let userId = authService.currentUser?.uid else { return }

        do {
            cart = try await orderService.fetchCart(userId: userId)
        } catch {
            print("Error loading cart: \(error.localizedDescription)")
        }
    }

    func loadOrders() async {
        guard let userId = authService.currentUser?.uid else { return }

        do {
            orders = try await orderService.fetchOrders(userId: userId)
        } catch {
            print("Error loading orders: \(error.localizedDescription)")
        }
    }

    // MARK: - Cart Management

    func removeFromCart(_ cartItemId: String) async {
        guard let userId = authService.currentUser?.uid else { return }

        do {
            try await orderService.removeFromCart(userId: userId, cartItemId: cartItemId)
            await loadCart()
            HapticManager.notification(.success)
        } catch {
            errorMessage = "Failed to remove item from cart"
            HapticManager.notification(.error)
        }
    }

    func clearCart() async {
        guard let userId = authService.currentUser?.uid else { return }

        do {
            try await orderService.clearCart(userId: userId)
            await loadCart()
            HapticManager.notification(.success)
        } catch {
            errorMessage = "Failed to clear cart"
            HapticManager.notification(.error)
        }
    }

    // MARK: - Order Management

    func placeOrder() async {
        guard let userId = authService.currentUser?.uid else { return }
        guard let cart = cart, !cart.items.isEmpty else {
            errorMessage = "Your cart is empty"
            return
        }

        isLoading = true

        do {
            _ = try await orderService.createOrder(userId: userId, cartItems: cart.items)
            await loadCart()
            await loadOrders()

            isLoading = false
            showSuccess("Order placed successfully!")
            HapticManager.notification(.success)
        } catch {
            isLoading = false
            errorMessage = "Failed to place order"
            HapticManager.notification(.error)
        }
    }

    func markItemAsCompleted(orderId: String, itemId: String) async {
        do {
            try await orderService.markItemAsCompleted(orderId: orderId, itemId: itemId)
            await loadOrders()
            await loadUserProfile() // Refresh to update statistics
            HapticManager.notification(.success)
        } catch {
            errorMessage = "Failed to mark item as completed"
            HapticManager.notification(.error)
        }
    }

    func markItemAsIncomplete(orderId: String, itemId: String) async {
        do {
            try await orderService.markItemAsIncomplete(orderId: orderId, itemId: itemId)
            await loadOrders()
            HapticManager.notification(.success)
        } catch {
            errorMessage = "Failed to mark item as incomplete"
            HapticManager.notification(.error)
        }
    }

    func deleteOrder(_ orderId: String) async {
        do {
            try await orderService.deleteOrder(orderId: orderId)
            await loadOrders()
            HapticManager.notification(.success)
        } catch {
            errorMessage = "Failed to delete order"
            HapticManager.notification(.error)
        }
    }

    // MARK: - User Profile Updates

    func updateUserName(_ name: String) async {
        guard let userId = authService.currentUser?.uid else { return }

        do {
            try await userService.updateUserName(userId: userId, name: name)
            await loadUserProfile()
            showSuccess("Name updated successfully")
        } catch {
            errorMessage = "Failed to update name"
        }
    }

    func updateNotificationPreference(_ enabled: Bool) async {
        guard let userId = authService.currentUser?.uid else { return }

        do {
            try await userService.updateNotificationPreference(userId: userId, enabled: enabled)
            await loadUserProfile()
        } catch {
            errorMessage = "Failed to update notification preference"
        }
    }

    func updateDailyGoal(_ minutes: Int) async {
        guard let userId = authService.currentUser?.uid else { return }

        do {
            try await userService.updateDailyGoal(userId: userId, minutes: minutes)
            await loadUserProfile()
            showSuccess("Daily goal updated")
        } catch {
            errorMessage = "Failed to update daily goal"
        }
    }

    // MARK: - Helper Methods

    private func showSuccess(_ message: String) {
        successMessage = message
        showSuccessMessage = true

        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            successMessage = ""
            showSuccessMessage = false
        }
    }

    func refresh() async {
        await loadUserProfile()
        await loadCart()
        await loadOrders()
    }

    // MARK: - Computed Properties

    var cartTotalDuration: Int {
        cart?.totalDuration ?? 0
    }

    var activeOrders: [Order] {
        orders.filter { $0.status == .active }
    }

    var completedOrders: [Order] {
        orders.filter { $0.status == .completed }
    }
}
