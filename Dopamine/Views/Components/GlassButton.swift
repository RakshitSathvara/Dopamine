//
//  GlassButton.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

struct GlassButton: View {
    let title: String
    var icon: String?
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = icon, !isLoading {
                    Image(systemName: icon)
                        .font(.bodyLarge)
                }

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(.bodyLarge)
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                ZStack {
                    LinearGradient(
                        colors: [
                            Color.purple.opacity(isDisabled ? 0.3 : 0.6),
                            Color.blue.opacity(isDisabled ? 0.3 : 0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.borderAccent, lineWidth: 1)
            }
            .shadow(color: Color.purple.opacity(isDisabled ? 0.1 : 0.3), radius: 15, x: 0, y: 8)
        }
        .disabled(isLoading || isDisabled)
    }
}
