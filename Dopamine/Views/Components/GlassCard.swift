//
//  GlassCard.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

struct GlassCard<Content: View>: View {
    let cornerRadius: CGFloat
    let content: Content

    init(
        cornerRadius: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.borderLight, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}
