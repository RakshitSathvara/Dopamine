//
//  UserService.swift
//  Dopamine
//
//  Service for managing user profiles in Firestore
//

import Foundation
import FirebaseFirestore

@MainActor
class UserService: ObservableObject {
    static let shared = UserService()

    @Published var currentUserProfile: User?

    private let db = Firestore.firestore()
    private let usersCollection = "users"

    private init() {}

    // MARK: - Create User Profile

    func createUserProfile(userId: String, email: String, name: String? = nil) async throws {
        let user = User(
            id: userId,
            email: email,
            name: name ?? email.components(separatedBy: "@").first ?? "User",
            createdAt: Date(),
            lastLoginAt: Date(),
            statistics: UserStatistics(
                currentStreak: 0,
                longestStreak: 0,
                totalActivitiesCompleted: 0,
                totalMinutes: 0
            ),
            preferences: UserPreferences(
                notificationsEnabled: true,
                darkMode: false,
                dailyGoal: 120
            )
        )

        do {
            try db.collection(usersCollection).document(userId).setData(from: user)
            currentUserProfile = user
            print("User profile created: \(userId)")
        } catch {
            print("Error creating user profile: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Fetch User Profile

    func fetchUserProfile(userId: String) async throws -> User {
        do {
            let document = try await db.collection(usersCollection).document(userId).getDocument()

            guard document.exists else {
                throw NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
            }

            let user = try document.data(as: User.self)
            currentUserProfile = user
            print("User profile fetched: \(userId)")
            return user
        } catch {
            print("Error fetching user profile: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Update User Profile

    func updateUserProfile(userId: String, updates: [String: Any]) async throws {
        do {
            try await db.collection(usersCollection).document(userId).updateData(updates)
            print("User profile updated: \(userId)")

            // Refresh current user profile
            try await fetchUserProfile(userId: userId)
        } catch {
            print("Error updating user profile: \(error.localizedDescription)")
            throw error
        }
    }

    func updateUserName(userId: String, name: String) async throws {
        try await updateUserProfile(userId: userId, updates: ["name": name])
    }

    func updateLastLogin(userId: String) async throws {
        try await updateUserProfile(userId: userId, updates: ["lastLoginAt": Timestamp(date: Date())])
    }

    // MARK: - Update User Statistics

    func updateStatistics(userId: String, statistics: UserStatistics) async throws {
        let updates: [String: Any] = [
            "statistics.currentStreak": statistics.currentStreak,
            "statistics.longestStreak": statistics.longestStreak,
            "statistics.totalActivitiesCompleted": statistics.totalActivitiesCompleted,
            "statistics.totalMinutes": statistics.totalMinutes
        ]

        try await updateUserProfile(userId: userId, updates: updates)
    }

    func incrementActivitiesCompleted(userId: String, duration: Int) async throws {
        guard let user = currentUserProfile else { return }

        var stats = user.statistics
        stats.totalActivitiesCompleted += 1
        stats.totalMinutes += duration

        try await updateStatistics(userId: userId, statistics: stats)
    }

    func updateStreak(userId: String, currentStreak: Int) async throws {
        guard let user = currentUserProfile else { return }

        var stats = user.statistics
        stats.currentStreak = currentStreak
        stats.longestStreak = max(stats.longestStreak, currentStreak)

        try await updateStatistics(userId: userId, statistics: stats)
    }

    // MARK: - Update User Preferences

    func updatePreferences(userId: String, preferences: UserPreferences) async throws {
        let updates: [String: Any] = [
            "preferences.notificationsEnabled": preferences.notificationsEnabled,
            "preferences.darkMode": preferences.darkMode,
            "preferences.dailyGoal": preferences.dailyGoal
        ]

        try await updateUserProfile(userId: userId, updates: updates)
    }

    func updateNotificationPreference(userId: String, enabled: Bool) async throws {
        try await updateUserProfile(userId: userId, updates: ["preferences.notificationsEnabled": enabled])
    }

    func updateDarkModePreference(userId: String, enabled: Bool) async throws {
        try await updateUserProfile(userId: userId, updates: ["preferences.darkMode": enabled])
    }

    func updateDailyGoal(userId: String, minutes: Int) async throws {
        try await updateUserProfile(userId: userId, updates: ["preferences.dailyGoal": minutes])
    }

    // MARK: - Real-time Listener

    func listenToUserProfile(userId: String, completion: @escaping (User?) -> Void) -> ListenerRegistration {
        return db.collection(usersCollection).document(userId).addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Error listening to user profile: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let document = documentSnapshot, document.exists else {
                completion(nil)
                return
            }

            do {
                let user = try document.data(as: User.self)
                Task { @MainActor in
                    self.currentUserProfile = user
                }
                completion(user)
            } catch {
                print("Error decoding user: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }

    // MARK: - Delete User

    func deleteUserProfile(userId: String) async throws {
        do {
            try await db.collection(usersCollection).document(userId).delete()
            currentUserProfile = nil
            print("User profile deleted: \(userId)")
        } catch {
            print("Error deleting user profile: \(error.localizedDescription)")
            throw error
        }
    }
}
