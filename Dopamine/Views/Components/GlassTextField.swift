//
//  GlassTextField.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

struct GlassTextField: View {
    @Binding var text: String
    let placeholder: String
    var icon: String?

    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.7))
                    .font(.textInput)
            }

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.white.opacity(0.5))
                        .font(.textInputPlaceholder)
                }
                TextField("", text: $text)
                    .foregroundColor(.white)
                    .font(.textInput)
                    .accentColor(.white)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}
