//
//  Cart.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import Foundation

struct CartItem: Identifiable, Codable, Equatable {
    let id: String
    let activityId: String
    let addedAt: Date
    let isUserActivity: Bool // true if it's a UserActivity, false if it's a system Activity

    var activity: Activity? {
        Activity.sampleActivities.first { $0.id == activityId }
    }
    
    init(id: String, activityId: String, addedAt: Date, isUserActivity: Bool = false) {
        self.id = id
        self.activityId = activityId
        self.addedAt = addedAt
        self.isUserActivity = isUserActivity
    }
    
    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        lhs.id == rhs.id && lhs.activityId == rhs.activityId && lhs.addedAt == rhs.addedAt && lhs.isUserActivity == rhs.isUserActivity
    }
}

struct Cart: Codable, Equatable {
    var items: [CartItem]
    var updatedAt: Date

    var totalDuration: Int {
        items.compactMap { $0.activity?.duration }.reduce(0, +)
    }

    static let sample = Cart(
        items: [
            CartItem(id: "cart_1", activityId: "1", addedAt: Date(), isUserActivity: false),
            CartItem(id: "cart_2", activityId: "4", addedAt: Date(), isUserActivity: false)
        ],
        updatedAt: Date()
    )
}
