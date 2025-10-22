//
//  DopamineApp.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI
import FirebaseCore

@main
struct DopamineApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var authService = AuthService.shared

    init() {
        // Configure Firebase
        FirebaseManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                MainTabView()
                    .preferredColorScheme(themeManager.currentTheme.colorScheme)
            } else {
                SplashView()
                    .preferredColorScheme(themeManager.currentTheme.colorScheme)
            }
        }
    }
}
