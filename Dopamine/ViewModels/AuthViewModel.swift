//
//  AuthViewModel.swift
//  Dopamine
//
//  ViewModel for handling authentication logic
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var otpCode: [String] = Array(repeating: "", count: 6)
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var isAuthenticated = false

    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Observe auth state changes
        authService.$isAuthenticated
            .assign(to: &$isAuthenticated)
    }

    // MARK: - Send OTP

    func sendOTP() async {
        guard !email.isEmpty else {
            showErrorMessage("Please enter your email address")
            return
        }

        guard isValidEmail(email) else {
            showErrorMessage("Please enter a valid email address")
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            // Send email link for authentication
            try await authService.sendEmailLink(email: email)
            isLoading = false
            HapticManager.notification(.success)
        } catch {
            isLoading = false
            showErrorMessage(error.localizedDescription)
            HapticManager.notification(.error)
        }
    }

    // MARK: - Verify OTP

    func verifyOTP(completion: @escaping (Bool) -> Void) async {
        let code = otpCode.joined()

        guard code.count == 6 else {
            showErrorMessage("Please enter the complete verification code")
            completion(false)
            return
        }

        isLoading = true
        errorMessage = nil

        // For development/testing: accept "123456" as valid OTP
        if code == "123456" {
            isLoading = false
            HapticManager.notification(.success)
            completion(true)
            return
        }

        // In production, you would verify with Firebase
        // For now, simulate verification
        do {
            try await Task.sleep(nanoseconds: 1_500_000_000)
            isLoading = false
            HapticManager.notification(.success)
            completion(true)
        } catch {
            isLoading = false
            showErrorMessage("Failed to verify code")
            HapticManager.notification(.error)
            completion(false)
        }
    }

    // MARK: - Verify Email Link

    func verifyEmailLink(link: String) async {
        if email.isEmpty {
            // Try to get saved email
            if let savedEmail = UserDefaults.standard.string(forKey: "EmailForSignIn") {
                email = savedEmail
            } else {
                showErrorMessage("Email not found. Please try logging in again.")
                return
            }
        }

        isLoading = true
        errorMessage = nil

        do {
            try await authService.verifyEmailLink(email: email, link: link)
            isLoading = false
            HapticManager.notification(.success)
        } catch {
            isLoading = false
            showErrorMessage(error.localizedDescription)
            HapticManager.notification(.error)
        }
    }

    // MARK: - Resend OTP

    func resendOTP() async {
        otpCode = Array(repeating: "", count: 6)
        await sendOTP()
    }

    // MARK: - Sign Out

    func signOut() {
        do {
            try authService.signOut()
            email = ""
            otpCode = Array(repeating: "", count: 6)
            HapticManager.notification(.success)
        } catch {
            showErrorMessage("Failed to sign out")
            HapticManager.notification(.error)
        }
    }

    // MARK: - Helper Methods

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true

        // Auto-hide error after 3 seconds
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            errorMessage = nil
            showError = false
        }
    }

    // MARK: - OTP Input Handling

    func handleOTPInput(at index: Int, value: String) -> Int? {
        if value.count == 1 && index < 5 {
            return index + 1 // Move to next field
        } else if value.isEmpty && index > 0 {
            return index - 1 // Move to previous field
        }
        return nil
    }

    func clearOTP() {
        otpCode = Array(repeating: "", count: 6)
    }
}
