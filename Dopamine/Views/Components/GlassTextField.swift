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
    var isSecure: Bool = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(colorScheme == .dark ?
                                     Color.white.opacity(0.6) :
                                     Color(red: 0.3, green: 0.25, blue: 0.35).opacity(0.7)
                    )
                    .font(.system(size: 16, weight: .medium))
            }

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(colorScheme == .dark ?
                                         Color.white.opacity(0.4) :
                                         Color(red: 0.4, green: 0.35, blue: 0.45).opacity(0.6)
                        )
                        .font(.system(size: 16))
                }

                if isSecure {
                    SecureField("", text: $text)
                        .foregroundColor(colorScheme == .dark ?
                                         Color.white :
                                         Color(red: 0.1, green: 0.05, blue: 0.15)
                        )
                        .font(.system(size: 16))
                        .accentColor(Color.purple)
                } else {
                    TextField("", text: $text)
                        .foregroundColor(colorScheme == .dark ?
                                         Color.white :
                                         Color(red: 0.1, green: 0.05, blue: 0.15)
                        )
                        .font(.system(size: 16))
                        .accentColor(Color.purple)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(colorScheme == .dark ?
                      Color.white.opacity(0.08) :
                      Color.white.opacity(0.5)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(colorScheme == .dark ?
                        Color.white.opacity(0.15) :
                        Color.white.opacity(0.6),
                        lineWidth: 1
                )
        )
    }
}
