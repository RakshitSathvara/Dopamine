//
//  EmptyStateView.swift
//  Dopamine
//
//  Created by Claude on 22/10/25.
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.2), Color.blue.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: icon)
                    .font(.system(size: 48, weight: .light))
                    .foregroundColor(.adaptiveSecondary)
            }

            // Text
            VStack(spacing: 8) {
                Text(title)
                    .font(.h2)
                    .foregroundColor(.adaptiveWhite)

                Text(message)
                    .font(.bodyRegular)
                    .foregroundColor(.adaptiveSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            // Action Button
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                            .font(.bodyRegular)
                        Text(actionTitle)
                            .font(.bodyRegular)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.adaptiveWhite)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.borderLight, lineWidth: 1)
                    )
                }
                .padding(.top, 8)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        icon: "cart.badge.questionmark",
        title: "No Items",
        message: "Your cart is empty. Add some activities to get started!",
        actionTitle: "Explore Activities",
        action: { }
    )
}
