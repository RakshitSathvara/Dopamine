//
//  AuthService.swift
//  Dopamine
//
//  Firebase Authentication service for email-based OTP login
//

import Foundation
import FirebaseAuth
import Combine

enum AuthError: LocalizedError {
    case invalidEmail
    case otpSendFailed
    case verificationFailed
    case userNotFound
    case networkError
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address"
        case .otpSendFailed:
            return "Failed to send OTP. Please try again."
        case .verificationFailed:
            return "Invalid OTP code. Please check and try again."
        case .userNotFound:
            return "User not found. Please sign up first."
        case .networkError:
            return "Network error. Please check your connection."
        case .unknown(let message):
            return message
        }
    }
}

@MainActor
class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var currentUser: FirebaseAuth.User?
    @Published var isAuthenticated = false

    private var handle: AuthStateDidChangeListenerHandle?

    private init() {
        setupAuthStateListener()
    }

    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Auth State Listener

    private func setupAuthStateListener() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = user != nil

                if let user = user {
                    print("User authenticated: \(user.uid)")
                } else {
                    print("User not authenticated")
                }
            }
        }
    }

    // MARK: - Email Link Authentication

    func sendEmailLink(email: String) async throws {
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }

        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.url = URL(string: "https://dopamine.app/finishSignUp")
        actionCodeSettings.handleCodeInApp = true
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier ?? "com.dopamine.app")

        do {
            try await Auth.auth().sendSignInLink(toEmail: email, actionCodeSettings: actionCodeSettings)
            // Save email for verification
            UserDefaults.standard.set(email, forKey: "EmailForSignIn")
            print("Email link sent to: \(email)")
        } catch {
            print("Error sending email link: \(error.localizedDescription)")
            throw AuthError.otpSendFailed
        }
    }

    // MARK: - Email/Password with OTP Simulation

    // Since Firebase doesn't have built-in email OTP, we'll use email link authentication
    // or you can implement custom backend OTP logic
    func sendOTPCode(to email: String) async throws {
        // For email-based OTP, we use Firebase email link
        try await sendEmailLink(email: email)
    }

    // Verify email link
    func verifyEmailLink(email: String, link: String) async throws {
        guard Auth.auth().isSignIn(withEmailLink: link) else {
            throw AuthError.verificationFailed
        }

        do {
            let result = try await Auth.auth().signIn(withEmail: email, link: link)
            currentUser = result.user

            // Clear saved email
            UserDefaults.standard.removeObject(forKey: "EmailForSignIn")

            // Create user profile if new user
            if result.additionalUserInfo?.isNewUser == true {
                try await UserService.shared.createUserProfile(userId: result.user.uid, email: email)
            }

            print("User signed in: \(result.user.uid)")
        } catch {
            print("Error verifying email link: \(error.localizedDescription)")
            throw AuthError.verificationFailed
        }
    }

    // MARK: - Alternative: Phone OTP (if you want SMS OTP)

    func sendPhoneOTP(phoneNumber: String) async throws {
        #if targetEnvironment(simulator)
        // For simulator testing
        print("Phone OTP simulation for: \(phoneNumber)")
        #else
        do {
            let verificationID = try await PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil)
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            print("Phone OTP sent to: \(phoneNumber)")
        } catch {
            print("Error sending phone OTP: \(error.localizedDescription)")
            throw AuthError.otpSendFailed
        }
        #endif
    }

    func verifyPhoneOTP(code: String) async throws {
        #if targetEnvironment(simulator)
        // For simulator testing - auto verify
        print("Phone OTP verification simulation with code: \(code)")
        #else
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {
            throw AuthError.verificationFailed
        }

        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: code
        )

        do {
            let result = try await Auth.auth().signIn(with: credential)
            currentUser = result.user

            // Create user profile if new user
            if result.additionalUserInfo?.isNewUser == true {
                try await UserService.shared.createUserProfile(
                    userId: result.user.uid,
                    email: result.user.email ?? ""
                )
            }

            UserDefaults.standard.removeObject(forKey: "authVerificationID")
            print("User signed in with phone: \(result.user.uid)")
        } catch {
            print("Error verifying phone OTP: \(error.localizedDescription)")
            throw AuthError.verificationFailed
        }
        #endif
    }

    // MARK: - Custom OTP (Backend Integration)

    // If you have a custom backend that sends OTP via email
    func sendCustomOTP(email: String) async throws {
        // TODO: Implement custom backend OTP send
        // This would call your backend API to send OTP via email
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }

        // Simulate OTP send
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("Custom OTP sent to: \(email)")
    }

    func verifyCustomOTP(email: String, code: String) async throws {
        // TODO: Implement custom backend OTP verification
        // This would:
        // 1. Verify OTP with your backend
        // 2. Get custom token from backend
        // 3. Sign in with custom token

        // Example implementation:
        // let customToken = try await getCustomToken(email: email, code: code)
        // let result = try await Auth.auth().signIn(withCustomToken: customToken)

        // For now, simulate verification
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("Custom OTP verified for: \(email)")
    }

    // MARK: - Sign Out

    func signOut() throws {
        do {
            try Auth.auth().signOut()
            currentUser = nil
            isAuthenticated = false
            print("User signed out successfully")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            throw AuthError.unknown(error.localizedDescription)
        }
    }

    // MARK: - Helper Methods

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    func updateLastLogin() async {
        guard let userId = currentUser?.uid else { return }
        try? await UserService.shared.updateLastLogin(userId: userId)
    }
}
