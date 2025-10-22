//
//  RegisterView.swift
//  Dopamine
//
//  Created by Rakshit on 22/10/25.
//

import SwiftUI

struct RegisterView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 32) {
                Spacer()

                // Header
                VStack(spacing: 12) {
                    Text("Create Account")
                        .font(.displayLarge)
                        .foregroundColor(.adaptiveWhite)

                    Text("Sign up to get started")
                        .font(.bodyRegular)
                        .foregroundColor(.adaptiveSecondary)
                }

                // Glass Input Container
                VStack(spacing: 20) {
                    // Email Input
                    GlassTextField(
                        text: $viewModel.email,
                        placeholder: "Email Address",
                        icon: "envelope.fill"
                    )
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()

                    // Password Input
                    GlassTextField(
                        text: $viewModel.password,
                        placeholder: "Password",
                        icon: "lock.fill",
                        isSecure: true
                    )
                    .textContentType(.newPassword)

                    // Confirm Password Input
                    GlassTextField(
                        text: $viewModel.confirmPassword,
                        placeholder: "Confirm Password",
                        icon: "lock.fill",
                        isSecure: true
                    )
                    .textContentType(.newPassword)

                    // Sign Up Button
                    GlassButton(
                        title: "Sign Up",
                        action: {
                            HapticManager.impact(.medium)
                            Task {
                                await viewModel.register()
                                // If registration is successful, dismiss the view
                                if viewModel.isAuthenticated {
                                    dismiss()
                                }
                            }
                        },
                        isLoading: viewModel.isLoading,
                        isDisabled: false
                    )

                    // Login Link
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .font(.bodyRegular)
                            .foregroundColor(.adaptiveSecondary)

                        Button(action: {
                            HapticManager.impact(.light)
                            dismiss()
                        }) {
                            Text("Login here")
                                .font(.bodyRegular)
                                .fontWeight(.semibold)
                                .foregroundColor(.adaptivePrimary)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.borderLight, lineWidth: 2)
                )
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 30)

                Spacer()

                // Footer
                HStack(spacing: 8) {
                    Text("Terms of Service")
                        .font(.caption)
                        .foregroundColor(.adaptiveTertiary)

                    Text("•")
                        .foregroundColor(.adaptiveTertiary)

                    Text("Privacy")
                        .font(.caption)
                        .foregroundColor(.adaptiveTertiary)
                }
                .padding(.bottom, 20)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

#Preview {
    RegisterView(viewModel: AuthViewModel())
}
