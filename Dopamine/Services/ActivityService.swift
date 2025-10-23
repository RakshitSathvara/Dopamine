//
//  ActivityService.swift
//  Dopamine
//
//  Service for managing activities in Firestore
//

import Foundation
import FirebaseFirestore
internal import Combine

@MainActor
class ActivityService: ObservableObject {
    static let shared = ActivityService()

    @Published var activities: [Activity] = []
    @Published var activitiesByCategory: [ActivityCategory: [Activity]] = [:]
    @Published var userActivities: [UserActivity] = []

    private let db = Firestore.firestore()
    private let activitiesCollection = "activities"
    private let userActivitiesCollection = "userActivities"

    private init() {}

    // MARK: - Fetch Activities

    func fetchActivities() async throws -> [Activity] {
        do {
            let snapshot = try await db.collection(activitiesCollection)
                .whereField("isActive", isEqualTo: true)
                .getDocuments()

            let fetchedActivities = try snapshot.documents.compactMap { document in
                try document.data(as: Activity.self)
            }

            activities = fetchedActivities
            organizeActivitiesByCategory()

            print("Fetched \(fetchedActivities.count) activities")
            return fetchedActivities
        } catch {
            print("Error fetching activities: \(error.localizedDescription)")
            // Fall back to sample data if Firebase fetch fails
            activities = Activity.sampleActivities
            organizeActivitiesByCategory()
            return Activity.sampleActivities
        }
    }

    func fetchActivities(for category: ActivityCategory) async throws -> [Activity] {
        do {
            let snapshot = try await db.collection(activitiesCollection)
                .whereField("category", isEqualTo: category.rawValue)
                .whereField("isActive", isEqualTo: true)
                .getDocuments()

            let fetchedActivities = try snapshot.documents.compactMap { document in
                try document.data(as: Activity.self)
            }

            print("Fetched \(fetchedActivities.count) activities for category: \(category.displayName)")
            return fetchedActivities
        } catch {
            print("Error fetching activities for category: \(error.localizedDescription)")
            // Fall back to sample data
            return Activity.activities(for: category)
        }
    }

    // MARK: - Get Single Activity

    func getActivity(by id: String) async throws -> Activity? {
        do {
            let document = try await db.collection(activitiesCollection).document(id).getDocument()

            guard document.exists else {
                return nil
            }

            return try document.data(as: Activity.self)
        } catch {
            print("Error fetching activity: \(error.localizedDescription)")
            // Fall back to sample data
            return Activity.sampleActivities.first { $0.id == id }
        }
    }

    // MARK: - Create Activity (Admin)

    func createActivity(_ activity: Activity) async throws {
        do {
            try db.collection(activitiesCollection).document(activity.id).setData(from: activity)
            print("Activity created: \(activity.name)")

            // Refresh activities list
            try await fetchActivities()
        } catch {
            print("Error creating activity: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Update Activity (Admin)

    func updateActivity(_ activity: Activity) async throws {
        do {
            try db.collection(activitiesCollection).document(activity.id).setData(from: activity, merge: true)
            print("Activity updated: \(activity.name)")

            // Refresh activities list
            try await fetchActivities()
        } catch {
            print("Error updating activity: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Delete Activity (Admin)

    func deleteActivity(id: String) async throws {
        do {
            try await db.collection(activitiesCollection).document(id).delete()
            print("Activity deleted: \(id)")

            // Refresh activities list
            try await fetchActivities()
        } catch {
            print("Error deleting activity: \(error.localizedDescription)")
            throw error
        }
    }

    // Soft delete - mark as inactive
    func deactivateActivity(id: String) async throws {
        do {
            try await db.collection(activitiesCollection).document(id).updateData(["isActive": false])
            print("Activity deactivated: \(id)")

            // Refresh activities list
            try await fetchActivities()
        } catch {
            print("Error deactivating activity: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Search Activities

    func searchActivities(query: String) -> [Activity] {
        guard !query.isEmpty else {
            return activities
        }

        return activities.filter { activity in
            activity.name.localizedCaseInsensitiveContains(query) ||
            activity.description.localizedCaseInsensitiveContains(query) ||
            activity.benefits.contains(where: { $0.localizedCaseInsensitiveContains(query) })
        }
    }

    // MARK: - Filter Activities

    func filterActivities(
        category: ActivityCategory? = nil,
        difficulty: Difficulty? = nil,
        minDuration: Int? = nil,
        maxDuration: Int? = nil
    ) -> [Activity] {
        var filtered = activities

        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }

        if let difficulty = difficulty {
            filtered = filtered.filter { $0.difficulty == difficulty }
        }

        if let minDuration = minDuration {
            filtered = filtered.filter { $0.duration >= minDuration }
        }

        if let maxDuration = maxDuration {
            filtered = filtered.filter { $0.duration <= maxDuration }
        }

        return filtered
    }

    // MARK: - Real-time Listener

    func listenToActivities(completion: @escaping ([Activity]) -> Void) -> ListenerRegistration {
        return db.collection(activitiesCollection)
            .whereField("isActive", isEqualTo: true)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error listening to activities: \(error.localizedDescription)")
                    completion([])
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    completion([])
                    return
                }

                let fetchedActivities = documents.compactMap { document -> Activity? in
                    try? document.data(as: Activity.self)
                }

                Task { @MainActor in
                    self.activities = fetchedActivities
                    self.organizeActivitiesByCategory()
                }

                completion(fetchedActivities)
            }
    }

    // MARK: - Seed Sample Data (For Testing)

    func seedSampleActivities() async throws {
        print("Seeding sample activities...")

        let batch = db.batch()

        for activity in Activity.sampleActivities {
            let docRef = db.collection(activitiesCollection).document(activity.id)

            // Create an activity with isActive field
            var activityDict = try Firestore.Encoder().encode(activity)
            activityDict["isActive"] = true

            batch.setData(activityDict, forDocument: docRef)
        }

        try await batch.commit()
        print("Sample activities seeded successfully")

        // Refresh activities list
        try await fetchActivities()
    }

    // MARK: - Helper Methods

    private func organizeActivitiesByCategory() {
        activitiesByCategory = Dictionary(grouping: activities, by: { $0.category })
    }

    // Get activities for a specific category from cached data
    func getActivities(for category: ActivityCategory) -> [Activity] {
        return activitiesByCategory[category] ?? []
    }

    // MARK: - User Activities

    func createUserActivity(userId: String, title: String, category: ActivityCategory, durationMinutes: Int, scheduledTime: Date, scheduledDate: Date) async throws -> UserActivity {
        let activity = UserActivity(
            userId: userId,
            title: title,
            category: category,
            durationMinutes: durationMinutes,
            scheduledTime: scheduledTime,
            scheduledDate: scheduledDate
        )

        do {
            let docRef = try db.collection(userActivitiesCollection).addDocument(from: activity)
            print("User activity created with ID: \(docRef.documentID)")

            // Refresh user activities
            try await fetchUserActivities(userId: userId)

            return activity
        } catch {
            print("Error creating user activity: \(error.localizedDescription)")
            throw error
        }
    }

    func fetchUserActivities(userId: String) async throws -> [UserActivity] {
        do {
            let snapshot = try await db.collection(userActivitiesCollection)
                .whereField("userId", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments()

            let fetchedActivities = try snapshot.documents.compactMap { document in
                try document.data(as: UserActivity.self)
            }

            userActivities = fetchedActivities
            print("Fetched \(fetchedActivities.count) user activities for user: \(userId)")
            return fetchedActivities
        } catch {
            print("Error fetching user activities: \(error.localizedDescription)")
            throw error
        }
    }

    func fetchUserActivitiesByCategory(userId: String, category: ActivityCategory) async throws -> [UserActivity] {
        do {
            let snapshot = try await db.collection(userActivitiesCollection)
                .whereField("userId", isEqualTo: userId)
                .whereField("category", isEqualTo: category.rawValue)
                .order(by: "createdAt", descending: true)
                .getDocuments()

            let activities = try snapshot.documents.compactMap { document in
                try document.data(as: UserActivity.self)
            }

            print("Fetched \(activities.count) user activities for category \(category.displayName)")
            return activities
        } catch {
            print("Error fetching user activities by category: \(error.localizedDescription)")
            throw error
        }
    }

    func deleteUserActivity(activityId: String) async throws {
        do {
            try await db.collection(userActivitiesCollection).document(activityId).delete()
            print("User activity deleted: \(activityId)")

            // Remove from local array
            userActivities.removeAll { $0.id == activityId }
        } catch {
            print("Error deleting user activity: \(error.localizedDescription)")
            throw error
        }
    }

    func listenToUserActivitiesByCategory(userId: String, category: ActivityCategory, completion: @escaping ([UserActivity]) -> Void) -> ListenerRegistration {
        return db.collection(userActivitiesCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("category", isEqualTo: category.rawValue)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error listening to user activities by category: \(error.localizedDescription)")
                    completion([])
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    completion([])
                    return
                }

                let activities = documents.compactMap { document -> UserActivity? in
                    try? document.data(as: UserActivity.self)
                }

                completion(activities)
            }
    }

    // MARK: - Add to Home Screen

    func addUserActivityToHomeScreen(activityId: String) async throws {
        do {
            try await db.collection(userActivitiesCollection).document(activityId).updateData([
                "isOnHomeScreen": true
            ])
            print("User activity added to home screen: \(activityId)")
        } catch {
            print("Error adding user activity to home screen: \(error.localizedDescription)")
            throw error
        }
    }

    func removeUserActivityFromHomeScreen(activityId: String) async throws {
        do {
            try await db.collection(userActivitiesCollection).document(activityId).updateData([
                "isOnHomeScreen": false
            ])
            print("User activity removed from home screen: \(activityId)")
        } catch {
            print("Error removing user activity from home screen: \(error.localizedDescription)")
            throw error
        }
    }

    func fetchHomeScreenUserActivities(userId: String) async throws -> [UserActivity] {
        do {
            let snapshot = try await db.collection(userActivitiesCollection)
                .whereField("userId", isEqualTo: userId)
                .whereField("isOnHomeScreen", isEqualTo: true)
                .order(by: "createdAt", descending: true)
                .getDocuments()

            let activities = try snapshot.documents.compactMap { document in
                try document.data(as: UserActivity.self)
            }

            print("Fetched \(activities.count) home screen user activities for user: \(userId)")
            return activities
        } catch {
            print("Error fetching home screen user activities: \(error.localizedDescription)")
            throw error
        }
    }

    func listenToHomeScreenUserActivities(userId: String, completion: @escaping ([UserActivity]) -> Void) -> ListenerRegistration {
        return db.collection(userActivitiesCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("isOnHomeScreen", isEqualTo: true)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error listening to home screen user activities: \(error.localizedDescription)")
                    completion([])
                    return
                }

                guard let documents = querySnapshot?.documents else {
                    completion([])
                    return
                }

                let activities = documents.compactMap { document -> UserActivity? in
                    try? document.data(as: UserActivity.self)
                }

                completion(activities)
            }
    }
}
