//
//  MainTabView.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }

                NavigationStack {
                    MenuView()
                }
                .tag(1)
                .tabItem {
                    Label("Menu", systemImage: "list.bullet")
                }

                ProfileView()
                    .tag(2)
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
            }
            .tint(.adaptiveWhite)
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            HapticManager.selection()
        }
    }
}

#Preview {
    MainTabView()
}
