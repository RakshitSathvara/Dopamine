//
//  SettingsView.swift
//  Dopamine
//
//  Created by Rakshit on 23/10/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showThemeSelector = false
    @State private var showLogoutConfirmation = false
    @State private var showDeleteAccountConfirmation = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Theme Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Appearance")
                        .font(.h2)
                        .foregroundColor(.adaptiveWhite)
                        .padding(.horizontal, 20)

                    ThemeSelectorCard(
                        currentTheme: $themeManager.currentTheme,
                        showThemeSelector: $showThemeSelector
                    )
                    .padding(.horizontal, 20)
                }

                // Account Management Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Account")
                        .font(.h2)
                        .foregroundColor(.adaptiveWhite)
                        .padding(.horizontal, 20)

                    accountManagementButtons
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 100)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .alert("Logout", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                Task {
                    do {
                        try await viewModel.logout()
                        HapticManager.notification(.success)
                    } catch {
                        HapticManager.notification(.error)
                    }
                }
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .alert("Delete Account", isPresented: $showDeleteAccountConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    do {
                        try await viewModel.deleteAccount()
                        HapticManager.notification(.success)
                    } catch {
                        HapticManager.notification(.error)
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.")
        }
    }

    private var accountManagementButtons: some View {
        VStack(spacing: 12) {
            // Logout Button
            Button {
                HapticManager.impact(.light)
                showLogoutConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.adaptiveWhite)

                    Text("Logout")
                        .font(.h3)
                        .foregroundColor(.adaptiveWhite)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.adaptiveTertiary)
                        .font(.caption)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.borderLight, lineWidth: 1)
                )
            }

            // Delete Account Button
            Button {
                HapticManager.impact(.light)
                showDeleteAccountConfirmation = true
            } label: {
                HStack {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red)

                    Text("Delete Account")
                        .font(.h3)
                        .foregroundColor(.red)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundColor(.adaptiveTertiary)
                        .font(.caption)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
