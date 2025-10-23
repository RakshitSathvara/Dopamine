//
//  MenuService.swift
//  Dopamine
//
//  Created by Claude on 23/10/2025.
//

import Foundation
import FirebaseFirestore
internal import Combine

/// Service responsible for managing dopamine menu configuration in Firestore
@MainActor
class MenuService: ObservableObject {
    static let shared = MenuService()

    @Published var menuConfiguration: MenuConfiguration?
    @Published var isLoading: Bool = false
    @Published var error: MenuError?

    private let db = Firestore.firestore()
    private let menuCollection = "menu"
    private let menuDocumentId = "categories"
    private var listener: ListenerRegistration?

    private init() {}

    // MARK: - Fetch Menu Configuration

    /// Fetches the menu configuration from Firestore
    /// - Returns: MenuConfiguration with all category descriptions
    /// - Throws: MenuError if fetch fails
    func fetchMenuConfiguration() async throws -> MenuConfiguration {
        isLoading = true
        error = nil

        do {
            let document = try await db.collection(menuCollection)
                .document(menuDocumentId)
                .getDocument()

            guard document.exists else {
                print("⚠️ Menu configuration not found in Firestore, using default")
                isLoading = false
                let defaultConfig = MenuConfiguration.default
                self.menuConfiguration = defaultConfig
                return defaultConfig
            }

            let data = document.data() ?? [:]
            let configuration = try parseMenuConfiguration(from: data)

            self.menuConfiguration = configuration
            isLoading = false

            print("✅ Successfully fetched menu configuration")
            return configuration

        } catch {
            isLoading = false
            self.error = .fetchFailed(error.localizedDescription)
            print("❌ Error fetching menu configuration: \(error.localizedDescription)")

            // Return default configuration as fallback
            let defaultConfig = MenuConfiguration.default
            self.menuConfiguration = defaultConfig
            return defaultConfig
        }
    }

    // MARK: - Real-time Listener

    /// Sets up a real-time listener for menu configuration changes
    /// - Returns: ListenerRegistration that can be used to stop listening
    func listenToMenuConfiguration() -> ListenerRegistration {
        let listener = db.collection(menuCollection)
            .document(menuDocumentId)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let self = self else { return }

                Task { @MainActor in
                    if let error = error {
                        print("❌ Error listening to menu configuration: \(error.localizedDescription)")
                        self.error = .fetchFailed(error.localizedDescription)
                        self.menuConfiguration = MenuConfiguration.default
                        return
                    }

                    guard let document = documentSnapshot, document.exists,
                          let data = document.data() else {
                        print("⚠️ Menu configuration document not found, using default")
                        self.menuConfiguration = MenuConfiguration.default
                        return
                    }

                    do {
                        let configuration = try self.parseMenuConfiguration(from: data)
                        self.menuConfiguration = configuration
                        print("✅ Menu configuration updated in real-time")
                    } catch {
                        print("❌ Error parsing menu configuration: \(error.localizedDescription)")
                        self.menuConfiguration = MenuConfiguration.default
                    }
                }
            }

        self.listener = listener
        return listener
    }

    /// Stops listening to menu configuration changes
    func stopListening() {
        listener?.remove()
        listener = nil
    }

    // MARK: - Seed Initial Data

    /// Seeds the Firestore database with default menu configuration
    /// This should be called once to initialize the menu in Firestore
    /// - Throws: MenuError if seeding fails
    func seedMenuConfiguration() async throws {
        print("🌱 Seeding menu configuration to Firestore...")

        let defaultConfig = MenuConfiguration.default

        do {
            let data = try serializeMenuConfiguration(defaultConfig)

            try await db.collection(menuCollection)
                .document(menuDocumentId)
                .setData(data)

            print("✅ Successfully seeded menu configuration")

            // Update local state
            self.menuConfiguration = defaultConfig

        } catch {
            print("❌ Error seeding menu configuration: \(error.localizedDescription)")
            throw MenuError.seedFailed(error.localizedDescription)
        }
    }

    // MARK: - Update Menu Configuration

    /// Updates a specific category's information in Firestore
    /// - Parameters:
    ///   - category: The activity category to update
    ///   - info: The new category information
    /// - Throws: MenuError if update fails
    func updateCategoryInfo(category: ActivityCategory, info: MenuCategoryInfo) async throws {
        let fieldName = getCategoryFieldName(for: category)

        let categoryData: [String: Any] = [
            "title": info.title,
            "description": info.description,
            "icon": info.icon,
            "order": info.order
        ]

        do {
            try await db.collection(menuCollection)
                .document(menuDocumentId)
                .updateData([
                    fieldName: categoryData,
                    "updatedAt": Timestamp(date: Date())
                ])

            print("✅ Successfully updated \(fieldName) category")

            // Refresh local configuration
            _ = try await fetchMenuConfiguration()

        } catch {
            print("❌ Error updating category: \(error.localizedDescription)")
            throw MenuError.updateFailed(error.localizedDescription)
        }
    }

    /// Updates the entire menu configuration
    /// - Parameter configuration: The new menu configuration
    /// - Throws: MenuError if update fails
    func updateMenuConfiguration(_ configuration: MenuConfiguration) async throws {
        do {
            let data = try serializeMenuConfiguration(configuration)

            try await db.collection(menuCollection)
                .document(menuDocumentId)
                .setData(data, merge: true)

            print("✅ Successfully updated entire menu configuration")

            self.menuConfiguration = configuration

        } catch {
            print("❌ Error updating menu configuration: \(error.localizedDescription)")
            throw MenuError.updateFailed(error.localizedDescription)
        }
    }

    // MARK: - Helper Methods

    /// Parses Firestore document data into MenuConfiguration
    private func parseMenuConfiguration(from data: [String: Any]) throws -> MenuConfiguration {
        // Parse each category
        guard let startersData = data["starters"] as? [String: Any],
              let mainsData = data["mains"] as? [String: Any],
              let sidesData = data["sides"] as? [String: Any],
              let dessertsData = data["desserts"] as? [String: Any],
              let specialsData = data["specials"] as? [String: Any] else {
            throw MenuError.parseFailed("Missing required category data")
        }

        let starters = try parseCategoryInfo(from: startersData)
        let mains = try parseCategoryInfo(from: mainsData)
        let sides = try parseCategoryInfo(from: sidesData)
        let desserts = try parseCategoryInfo(from: dessertsData)
        let specials = try parseCategoryInfo(from: specialsData)

        let updatedAt: Date
        if let timestamp = data["updatedAt"] as? Timestamp {
            updatedAt = timestamp.dateValue()
        } else {
            updatedAt = Date()
        }

        return MenuConfiguration(
            starters: starters,
            mains: mains,
            sides: sides,
            desserts: desserts,
            specials: specials,
            updatedAt: updatedAt
        )
    }

    /// Parses a single category info from Firestore data
    private func parseCategoryInfo(from data: [String: Any]) throws -> MenuCategoryInfo {
        guard let title = data["title"] as? String,
              let description = data["description"] as? String,
              let icon = data["icon"] as? String,
              let order = data["order"] as? Int else {
            throw MenuError.parseFailed("Missing required category fields")
        }

        return MenuCategoryInfo(
            title: title,
            description: description,
            icon: icon,
            order: order
        )
    }

    /// Serializes MenuConfiguration to Firestore-compatible dictionary
    private func serializeMenuConfiguration(_ config: MenuConfiguration) throws -> [String: Any] {
        return [
            "starters": serializeCategoryInfo(config.starters),
            "mains": serializeCategoryInfo(config.mains),
            "sides": serializeCategoryInfo(config.sides),
            "desserts": serializeCategoryInfo(config.desserts),
            "specials": serializeCategoryInfo(config.specials),
            "updatedAt": Timestamp(date: config.updatedAt)
        ]
    }

    /// Serializes a single category info to Firestore-compatible dictionary
    private func serializeCategoryInfo(_ info: MenuCategoryInfo) -> [String: Any] {
        return [
            "title": info.title,
            "description": info.description,
            "icon": info.icon,
            "order": info.order
        ]
    }

    /// Gets the Firestore field name for a category
    private func getCategoryFieldName(for category: ActivityCategory) -> String {
        switch category {
        case .starters: return "starters"
        case .mains: return "mains"
        case .sides: return "sides"
        case .desserts: return "desserts"
        case .special: return "specials"
        }
    }

    // MARK: - Convenience Methods

    /// Gets category info for a specific category, returns default if not loaded
    func getCategoryInfo(for category: ActivityCategory) -> MenuCategoryInfo {
        guard let config = menuConfiguration else {
            return MenuConfiguration.default.getCategoryInfo(for: category)
        }
        return config.getCategoryInfo(for: category)
    }
}

// MARK: - Menu Error

enum MenuError: LocalizedError {
    case fetchFailed(String)
    case updateFailed(String)
    case seedFailed(String)
    case parseFailed(String)

    var errorDescription: String? {
        switch self {
        case .fetchFailed(let message):
            return "Failed to fetch menu: \(message)"
        case .updateFailed(let message):
            return "Failed to update menu: \(message)"
        case .seedFailed(let message):
            return "Failed to seed menu: \(message)"
        case .parseFailed(let message):
            return "Failed to parse menu: \(message)"
        }
    }
}
