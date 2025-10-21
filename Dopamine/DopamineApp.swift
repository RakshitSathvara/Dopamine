//
//  DopamineApp.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

@main
struct DopamineApp: App {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
        }
    }
}
