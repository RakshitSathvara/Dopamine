//
//  LoginView.swift
//  Dopamine
//
//  Created by Rakshit on 21/10/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showRegisterView = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: colorScheme == .dark ?
                    [Color(red: 0.1, green: 0.05, blue: 0.15), Color(red: 0.15, green: 0.1, blue: 0.2), Color(red: 0.08, green: 0.05, blue: 0.15)] :
                    [Color(red: 0.95, green: 0.93, blue: 0.98), Color(red: 0.98, green: 0.96, blue: 1.0), Color(red: 0.93, green: 0.95, blue: 0.98)]
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Decorative Circles
            GeometryReader { geometry in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 300, height: 300)
                    .blur(radius: 60)
                    .offset(x: -100, y: -50)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.25), Color.purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 250, height: 250)
                    .blur(radius: 50)
                    .offset(x: geometry.size.width - 150, y: geometry.size.height - 200)
            }

            ScrollView {
                VStack(spacing: 40) {
                    Spacer()
                        .frame(height: 60)

                    // App Logo/Icon
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple.opacity(0.6), Color.blue.opacity(0.6)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)

                            Text("D")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .shadow(color: Color.purple.opacity(0.4), radius: 15, x: 0, y: 8)

                        Text("Dopamine")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.1, green: 0.05, blue: 0.15))
                    }

                    // Header
                    VStack(spacing: 8) {
                        Text("Welcome Back")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(colorScheme == .dark ? .white : Color(red: 0.1, green: 0.05, blue: 0.15))

                        Text("Sign in to continue your journey")
                            .font(.system(size: 16))
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(red: 0.3, green: 0.25, blue: 0.35))
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
                        .textContentType(.password)

                        // Forgot Password
                        HStack {
                            Spacer()
                            Button(action: {
                                // TODO: Implement forgot password
                                HapticManager.impact(.light)
                            }) {
                                Text("Forgot Password?")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color.purple)
                            }
                        }

                        // Login Button
                        GlassButton(
                            title: "Login",
                            action: {
                                HapticManager.impact(.medium)
                                Task {
                                    await viewModel.login()
                                }
                            },
                            isLoading: viewModel.isLoading,
                            isDisabled: false
                        )
                        .padding(.top, 8)

                        // Register Link
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .font(.system(size: 15))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.7) : Color(red: 0.3, green: 0.25, blue: 0.35))

                            Button(action: {
                                HapticManager.impact(.light)
                                showRegisterView = true
                            }) {
                                Text("Sign Up")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color.purple)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding(28)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(colorScheme == .dark ?
                                  Color.white.opacity(0.1) :
                                  Color.white.opacity(0.7)
                            )
                            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 20, x: 0, y: 10)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: colorScheme == .dark ?
                                        [Color.white.opacity(0.3), Color.white.opacity(0.1)] :
                                        [Color.white.opacity(0.8), Color.white.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .padding(.horizontal, 30)

                    // Footer
                    HStack(spacing: 8) {
                        Button(action: {
                            // TODO: Open Terms of Service
                        }) {
                            Text("Terms of Service")
                                .font(.system(size: 13))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.5) : Color(red: 0.4, green: 0.35, blue: 0.45))
                        }

                        Text("•")
                            .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.5) : Color(red: 0.4, green: 0.35, blue: 0.45))

                        Button(action: {
                            // TODO: Open Privacy Policy
                        }) {
                            Text("Privacy")
                                .font(.system(size: 13))
                                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.5) : Color(red: 0.4, green: 0.35, blue: 0.45))
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .fullScreenCover(isPresented: $showRegisterView) {
            RegisterView(viewModel: viewModel)
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
