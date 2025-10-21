//
//  HapticManager.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import UIKit

class HapticManager {
    // Check if haptics are supported on the current device
    private static var isHapticsAvailable: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isHapticsAvailable else { return }

        // Prepare and trigger haptic feedback safely
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isHapticsAvailable else { return }

        // Prepare and trigger haptic feedback safely
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    static func selection() {
        guard isHapticsAvailable else { return }

        // Prepare and trigger haptic feedback safely
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
