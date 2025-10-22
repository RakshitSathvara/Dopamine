//
//  FirebaseManager.swift
//  Dopamine
//
//  Firebase initialization and configuration manager
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class FirebaseManager {
    static let shared = FirebaseManager()

    private init() {}

    func configure() {
        // Configure Firebase
        FirebaseApp.configure()

        // Configure Firestore settings
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true
        settings.cacheSettings = PersistentCacheSettings()

        Firestore.firestore().settings = settings

        print("Firebase configured successfully")
    }

    // Get Firestore instance
    var firestore: Firestore {
        return Firestore.firestore()
    }

    // Get Auth instance
    var auth: Auth {
        return Auth.auth()
    }
}
