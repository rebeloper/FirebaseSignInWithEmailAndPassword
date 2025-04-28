//
//  FirebaseSignInWithEmailAnPasswordControllerEnvironmentValues+.swift
//  FirebaseSignInWithEmailAndPassword
//
//  Created by Alex Nagy on 28.04.2025.
//

import SwiftUI

public struct FirebaseSignInWithEmailAndPasswordKey: EnvironmentKey {
    @MainActor
    public static var defaultValue = FirebaseSignInWithEmailAndPasswordController()
}

public extension EnvironmentValues {
    @MainActor
    var firebaseSignInWithEmailAndPassword: FirebaseSignInWithEmailAndPasswordController {
        get { self[FirebaseSignInWithEmailAndPasswordKey.self] }
        set { self[FirebaseSignInWithEmailAndPasswordKey.self] = newValue }
    }
}
