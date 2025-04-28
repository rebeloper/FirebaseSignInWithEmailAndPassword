//
//  FirebaseSignInWithEmailAndPasswordNotificationCenter+.swift
//  FirebaseSignInWithEmailAndPassword
//
//  Created by Alex Nagy on 28.04.2025.
//

import Foundation
import FirebaseCore

public extension NotificationCenter {
    static func post(error: Error) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name.firebaseSignInWithEmailAndPasswordError, object: error.localizedDescription)
        }
    }
}
