//
//  LoginView.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showOTPView = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 32) {
                Spacer()

                // Header
                VStack(spacing: 12) {
                    Text("Welcome Back")
                        .font(.displayLarge)
                        .foregroundColor(.adaptiveWhite)

                    Text("Enter your email to continue")
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

                    // Send OTP Button
                    GlassButton(
                        title: "Send OTP Code",
                        action: {
                            HapticManager.impact(.medium)
                            Task {
                                await viewModel.sendOTP()
                                if !viewModel.showError {
                                    showOTPView = true
                                }
                            }
                        },
                        isLoading: viewModel.isLoading,
                        isDisabled: false
                    )
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
        .fullScreenCover(isPresented: $showOTPView) {
            OTPVerificationView(viewModel: viewModel)
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
    LoginView()
}
