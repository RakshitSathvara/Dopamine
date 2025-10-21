//
//  Order.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import Foundation

enum OrderStatus: String, Codable {
    case pending
    case active
    case completed
    case cancelled

    var displayName: String {
        self.rawValue.capitalized
    }
}

struct OrderItem: Identifiable, Codable {
    let id: String
    let activityId: String
    let activityName: String
    let duration: Int
    var isCompleted: Bool
    var completedAt: Date?
}

struct Order: Identifiable, Codable {
    let id: String
    let userId: String
    var items: [OrderItem]
    var status: OrderStatus
    let createdAt: Date
    var completedAt: Date?

    var totalDuration: Int {
        items.reduce(0) { $0 + $1.duration }
    }

    var completedItemsCount: Int {
        items.filter { $0.isCompleted }.count
    }

    var completionPercentage: Double {
        guard !items.isEmpty else { return 0 }
        return Double(completedItemsCount) / Double(items.count) * 100
    }

    static let sampleOrders: [Order] = [
        Order(
            id: "order_1",
            userId: "user_1",
            items: [
                OrderItem(
                    id: "item_1",
                    activityId: "1",
                    activityName: "5-Min Breathing",
                    duration: 5,
                    isCompleted: true,
                    completedAt: Date().addingTimeInterval(-3600)
                ),
                OrderItem(
                    id: "item_2",
                    activityId: "4",
                    activityName: "Deep Work Session",
                    duration: 90,
                    isCompleted: true,
                    completedAt: Date().addingTimeInterval(-1800)
                ),
                OrderItem(
                    id: "item_3",
                    activityId: "10",
                    activityName: "Evening Reading",
                    duration: 30,
                    isCompleted: true,
                    completedAt: Date().addingTimeInterval(-900)
                )
            ],
            status: .completed,
            createdAt: Date(),
            completedAt: Date()
        ),
        Order(
            id: "order_2",
            userId: "user_1",
            items: [
                OrderItem(
                    id: "item_4",
                    activityId: "2",
                    activityName: "Morning Stretch",
                    duration: 10,
                    isCompleted: true,
                    completedAt: Date().addingTimeInterval(-86400)
                ),
                OrderItem(
                    id: "item_5",
                    activityId: "6",
                    activityName: "Learning Session",
                    duration: 45,
                    isCompleted: true,
                    completedAt: Date().addingTimeInterval(-82800)
                )
            ],
            status: .completed,
            createdAt: Date().addingTimeInterval(-86400),
            completedAt: Date().addingTimeInterval(-82800)
        )
    ]
}
