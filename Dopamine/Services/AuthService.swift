//
//  AuthService.swift
//  Dopamine
//
//  Firebase Authentication service for email-based OTP login
//

import Foundation
import FirebaseAuth
internal import Combine

enum AuthError: LocalizedError {
    case invalidEmail
    case otpSendFailed
    case verificationFailed
    case userNotFound
    case networkError
    case weakPassword
    case emailAlreadyInUse
    case wrongPassword
    case invalidCredentials
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
        case .weakPassword:
            return "Password should be at least 6 characters"
        case .emailAlreadyInUse:
            return "This email is already registered. Please login instead."
        case .wrongPassword:
            return "Incorrect password. Please try again."
        case .invalidCredentials:
            return "Invalid email or password"
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
        // Use localhost for development - it's pre-authorized in Firebase
        // For production, add your domain to Firebase Console → Authentication → Settings → Authorized domains
        actionCodeSettings.url = URL(string: "http://localhost/finishSignUp?email=\(email)")
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

    // Generate and send OTP for email authentication
    func sendCustomOTP(email: String) async throws {
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }

        // Generate 6-digit OTP
        let otp = generateOTP()

        // Save OTP and email for verification
        let otpData: [String: Any] = [
            "otp": otp,
            "email": email,
            "timestamp": Date().timeIntervalSince1970
        ]
        UserDefaults.standard.set(otpData, forKey: "PendingOTP")

        // In production, send OTP via email using your backend
        // For development, print it to console
        print("📧 OTP Code for \(email): \(otp)")
        print("💡 For testing, you can also use: 123456")

        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)
    }

    func verifyCustomOTP(email: String, code: String) async throws {
        // Accept universal test code
        if code == "123456" {
            print("✅ Using test OTP code")
            try await signInOrCreateUser(email: email)
            return
        }

        // Verify against saved OTP
        guard let otpData = UserDefaults.standard.dictionary(forKey: "PendingOTP"),
              let savedOTP = otpData["otp"] as? String,
              let savedEmail = otpData["email"] as? String,
              let timestamp = otpData["timestamp"] as? TimeInterval else {
            throw AuthError.verificationFailed
        }

        // Check if OTP is expired (5 minutes)
        let expirationTime: TimeInterval = 5 * 60
        if Date().timeIntervalSince1970 - timestamp > expirationTime {
            UserDefaults.standard.removeObject(forKey: "PendingOTP")
            throw AuthError.unknown("OTP code has expired. Please request a new one.")
        }

        // Verify email and OTP match
        guard email == savedEmail, code == savedOTP else {
            throw AuthError.verificationFailed
        }

        // Clear OTP data
        UserDefaults.standard.removeObject(forKey: "PendingOTP")

        // Sign in or create user
        try await signInOrCreateUser(email: email)
    }

    // MARK: - Helper Methods for OTP

    private func generateOTP() -> String {
        let otp = Int.random(in: 100000...999999)
        return String(otp)
    }

    private func signInOrCreateUser(email: String) async throws {
        // For OTP-based auth, we'll use a fixed password derived from the email
        // In production, you might want to use Firebase Custom Auth or Anonymous auth
        let password = "OTP_AUTH_\(email.hash)"

        do {
            // Try to sign in first
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            currentUser = result.user
            print("✅ User signed in: \(result.user.uid)")
        } catch let error as NSError {
            // If user doesn't exist, create account
            if error.code == AuthErrorCode.userNotFound.rawValue ||
               error.code == AuthErrorCode.wrongPassword.rawValue {
                do {
                    let result = try await Auth.auth().createUser(withEmail: email, password: password)
                    currentUser = result.user

                    // Create user profile for new user
                    try await UserService.shared.createUserProfile(userId: result.user.uid, email: email)
                    print("✅ New user created: \(result.user.uid)")
                } catch {
                    print("❌ Error creating user: \(error.localizedDescription)")
                    throw AuthError.unknown("Failed to create user account")
                }
            } else {
                print("❌ Error signing in: \(error.localizedDescription)")
                throw AuthError.verificationFailed
            }
        }
    }

    // MARK: - Password Authentication

    func signUp(email: String, password: String) async throws {
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }

        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }

        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            currentUser = result.user

            // Create user profile for new user
            try await UserService.shared.createUserProfile(userId: result.user.uid, email: email)
            print("✅ New user created: \(result.user.uid)")
        } catch let error as NSError {
            print("❌ Error creating user: \(error.localizedDescription)")

            // Handle specific Firebase errors
            if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                throw AuthError.emailAlreadyInUse
            } else if error.code == AuthErrorCode.weakPassword.rawValue {
                throw AuthError.weakPassword
            } else if error.code == AuthErrorCode.invalidEmail.rawValue {
                throw AuthError.invalidEmail
            } else {
                throw AuthError.unknown(error.localizedDescription)
            }
        }
    }

    func signIn(email: String, password: String) async throws {
        guard isValidEmail(email) else {
            throw AuthError.invalidEmail
        }

        guard !password.isEmpty else {
            throw AuthError.unknown("Please enter your password")
        }

        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            currentUser = result.user
            print("✅ User signed in: \(result.user.uid)")
        } catch let error as NSError {
            print("❌ Error signing in: \(error.localizedDescription)")

            // Handle specific Firebase errors
            if error.code == AuthErrorCode.userNotFound.rawValue {
                throw AuthError.userNotFound
            } else if error.code == AuthErrorCode.wrongPassword.rawValue {
                throw AuthError.wrongPassword
            } else if error.code == AuthErrorCode.invalidEmail.rawValue {
                throw AuthError.invalidEmail
            } else if error.code == AuthErrorCode.invalidCredential.rawValue {
                throw AuthError.invalidCredentials
            } else {
                throw AuthError.unknown(error.localizedDescription)
            }
        }
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
