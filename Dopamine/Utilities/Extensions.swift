//
//  Extensions.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

// MARK: - String Extensions
extension String {
    var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
}

// MARK: - View Extensions
extension View {
    func glassEffect(cornerRadius: CGFloat = 16) -> some View {
        self
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

    func animatedAppearance(delay: Double = 0) -> some View {
        self
            .opacity(0)
            .offset(y: 20)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    // Animation handled by the view state
                }
            }
    }
}

// MARK: - Date Extensions
extension Date {
    func formatRelative() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }

    func formatShort() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    func formatTime() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
}

// MARK: - Animation Extensions
extension Animation {
    static let glassSpring = Animation.spring(
        response: 0.6,
        dampingFraction: 0.7
    )

    static let liquidSpring = Animation.spring(
        response: 0.5,
        dampingFraction: 0.8
    )
}
