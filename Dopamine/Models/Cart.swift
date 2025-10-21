//
//  Cart.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import Foundation

struct CartItem: Identifiable, Codable {
    let id: String
    let activityId: String
    let addedAt: Date

    var activity: Activity? {
        Activity.sampleActivities.first { $0.id == activityId }
    }
}

struct Cart: Codable {
    var items: [CartItem]
    var updatedAt: Date

    var totalDuration: Int {
        items.compactMap { $0.activity?.duration }.reduce(0, +)
    }

    static let sample = Cart(
        items: [
            CartItem(id: "cart_1", activityId: "1", addedAt: Date()),
            CartItem(id: "cart_2", activityId: "4", addedAt: Date())
        ],
        updatedAt: Date()
    )
}
