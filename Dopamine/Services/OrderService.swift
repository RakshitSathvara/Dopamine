//
//  OrderService.swift
//  Dopamine
//
//  Service for managing orders and carts in Firestore
//

import Foundation
import FirebaseFirestore
internal import Combine

class OrderService: ObservableObject {
    static let shared = OrderService()

    @Published var currentCart: Cart?
    @Published var orders: [Order] = []

    private let db = Firestore.firestore()
    private let cartsCollection = "carts"
    private let ordersCollection = "orders"

    private init() {}

    // MARK: - Cart Management

    func fetchCart(userId: String) async throws -> Cart {
        do {
            let document = try await db.collection(cartsCollection).document(userId).getDocument()

            if document.exists {
                let cart = try document.data(as: Cart.self)
                currentCart = cart
                return cart
            } else {
                // Create empty cart
                let newCart = Cart(items: [], updatedAt: Date())
                try db.collection(cartsCollection).document(userId).setData(from: newCart)
                currentCart = newCart
                return newCart
            }
        } catch {
            print("Error fetching cart: \(error.localizedDescription)")
            throw error
        }
    }

    func addToCart(userId: String, activityId: String, isUserActivity: Bool = false) async throws {
        let cartItem = CartItem(
            id: UUID().uuidString,
            activityId: activityId,
            addedAt: Date(),
            isUserActivity: isUserActivity
        )

        do {
            let cartRef = db.collection(cartsCollection).document(userId)
            let document = try await cartRef.getDocument()

            if document.exists {
                try await cartRef.updateData([
                    "items": FieldValue.arrayUnion([try Firestore.Encoder().encode(cartItem)]),
                    "updatedAt": Timestamp(date: Date())
                ])
            } else {
                let newCart = Cart(items: [cartItem], updatedAt: Date())
                try cartRef.setData(from: newCart)
            }

            print("\(isUserActivity ? "User activity" : "Activity") added to cart: \(activityId)")

            // Refresh cart
            try await fetchCart(userId: userId)
        } catch {
            print("Error adding to cart: \(error.localizedDescription)")
            throw error
        }
    }

    func removeFromCart(userId: String, cartItemId: String) async throws {
        do {
            let cart = try await fetchCart(userId: userId)
            let updatedItems = cart.items.filter { $0.id != cartItemId }

            try await db.collection(cartsCollection).document(userId).updateData([
                "items": try updatedItems.map { try Firestore.Encoder().encode($0) },
                "updatedAt": Timestamp(date: Date())
            ])

            print("Item removed from cart: \(cartItemId)")

            // Refresh cart
            try await fetchCart(userId: userId)
        } catch {
            print("Error removing from cart: \(error.localizedDescription)")
            throw error
        }
    }

    func clearCart(userId: String) async throws {
        do {
            try await db.collection(cartsCollection).document(userId).updateData([
                "items": [],
                "updatedAt": Timestamp(date: Date())
            ])

            currentCart = Cart(items: [], updatedAt: Date())
            print("Cart cleared for user: \(userId)")
        } catch {
            print("Error clearing cart: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Order Management

    func createOrder(userId: String, cartItems: [CartItem]) async throws -> Order {
        // Create order items from cart items
        let orderItems = try await createOrderItems(from: cartItems)

        let order = Order(
            id: UUID().uuidString,
            userId: userId,
            items: orderItems,
            status: .active,
            createdAt: Date(),
            completedAt: nil
        )

        do {
            try db.collection(ordersCollection).document(order.id).setData(from: order)
            print("Order created: \(order.id)")

            // Clear cart
            try await clearCart(userId: userId)

            // Refresh orders
            try await fetchOrders(userId: userId)

            return order
        } catch {
            print("Error creating order: \(error.localizedDescription)")
            throw error
        }
    }

    func fetchOrders(userId: String) async throws -> [Order] {
        do {
            let snapshot = try await db.collection(ordersCollection)
                .whereField("userId", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments()

            let fetchedOrders = try snapshot.documents.compactMap { document in
                try document.data(as: Order.self)
            }

            orders = fetchedOrders
            print("Fetched \(fetchedOrders.count) orders for user: \(userId)")
            return fetchedOrders
        } catch {
            print("Error fetching orders: \(error.localizedDescription)")
            throw error
        }
    }

    func getOrder(orderId: String) async throws -> Order {
        do {
            let document = try await db.collection(ordersCollection).document(orderId).getDocument()

            guard document.exists else {
                throw NSError(domain: "OrderService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Order not found"])
            }

            return try document.data(as: Order.self)
        } catch {
            print("Error fetching order: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Update Order

    func updateOrderStatus(orderId: String, status: OrderStatus) async throws {
        var updates: [String: Any] = ["status": status.rawValue]

        if status == .completed {
            updates["completedAt"] = Timestamp(date: Date())
        }

        do {
            try await db.collection(ordersCollection).document(orderId).updateData(updates)
            print("Order status updated: \(orderId) -> \(status.rawValue)")

            // Refresh orders if we have a current user
            if let userId = orders.first?.userId {
                try await fetchOrders(userId: userId)
            }
        } catch {
            print("Error updating order status: \(error.localizedDescription)")
            throw error
        }
    }

    func markItemAsCompleted(orderId: String, itemId: String) async throws {
        do {
            let order = try await getOrder(orderId: orderId)
            var updatedItems = order.items

            if let index = updatedItems.firstIndex(where: { $0.id == itemId }) {
                updatedItems[index].isCompleted = true
                updatedItems[index].completedAt = Date()

                try await db.collection(ordersCollection).document(orderId).updateData([
                    "items": try updatedItems.map { try Firestore.Encoder().encode($0) }
                ])

                print("Order item marked as completed: \(itemId)")

                // Check if all items are completed
                if updatedItems.allSatisfy({ $0.isCompleted }) {
                    try await updateOrderStatus(orderId: orderId, status: .completed)

                    // Update user statistics
                    if let userId = order.userId as String? {
                        let totalDuration = order.totalDuration
                        try await UserService.shared.incrementActivitiesCompleted(userId: userId, duration: totalDuration)
                    }
                }

                // Refresh orders
                if let userId = order.userId as String? {
                    try await fetchOrders(userId: userId)
                }
            }
        } catch {
            print("Error marking item as completed: \(error.localizedDescription)")
            throw error
        }
    }

    func markItemAsIncomplete(orderId: String, itemId: String) async throws {
        do {
            let order = try await getOrder(orderId: orderId)
            var updatedItems = order.items

            if let index = updatedItems.firstIndex(where: { $0.id == itemId }) {
                updatedItems[index].isCompleted = false
                updatedItems[index].completedAt = nil

                try await db.collection(ordersCollection).document(orderId).updateData([
                    "items": try updatedItems.map { try Firestore.Encoder().encode($0) }
                ])

                print("Order item marked as incomplete: \(itemId)")

                // Refresh orders
                if let userId = order.userId as String? {
                    try await fetchOrders(userId: userId)
                }
            }
        } catch {
            print("Error marking item as incomplete: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Delete Order

    func deleteOrder(orderId: String) async throws {
        do {
            try await db.collection(ordersCollection).document(orderId).delete()
            print("Order deleted: \(orderId)")

            // Remove from local array
            orders.removeAll { $0.id == orderId }
        } catch {
            print("Error deleting order: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Real-time Listeners

    func listenToCart(userId: String, completion: @escaping (Cart?) -> Void) -> ListenerRegistration {
        return db.collection(cartsCollection).document(userId).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Error listening to cart: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let document = documentSnapshot, document.exists else {
                completion(nil)
                return
            }

            do {
                let cart = try document.data(as: Cart.self)
                Task { @MainActor in
                    self.currentCart = cart
                }
                completion(cart)
            } catch {
                print("Error decoding cart: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

    func listenToOrders(userId: String, completion: @escaping ([Order]) -> Void) -> ListenerRegistration {
        return db.collection(ordersCollection)
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error listening to orders: \(error.localizedDescription)")
                    completion([])
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    completion([])
                    return
                }

                let fetchedOrders = documents.compactMap { document -> Order? in
                    try? document.data(as: Order.self)
                }

                Task { @MainActor in
                    self.orders = fetchedOrders
                }

                completion(fetchedOrders)
            }
    }

    // MARK: - Helper Methods

    private func createOrderItems(from cartItems: [CartItem]) async throws -> [OrderItem] {
        var orderItems: [OrderItem] = []

        for cartItem in cartItems {
            if let activity = cartItem.activity {
                let orderItem = OrderItem(
                    id: UUID().uuidString,
                    activityId: activity.id,
                    activityName: activity.name,
                    duration: activity.duration,
                    isCompleted: false,
                    completedAt: nil
                )
                orderItems.append(orderItem)
            }
        }

        return orderItems
    }
}
