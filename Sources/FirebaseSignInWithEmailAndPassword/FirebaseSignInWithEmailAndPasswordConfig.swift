//
//  FirebaseSignInWithEmailAndPasswordConfig.swift
//  FirebaseSignInWithEmailAndPassword
//
//  Created by Alex Nagy on 28.04.2025.
//

import SwiftUI
import FirebaseAuth

struct FirestoreUserCollectionPathModifier: ViewModifier {
    
    @State private var controller = FirebaseSignInWithEmailAndPasswordController()
    @State private var isErrorAlertPresented = false
    @State private var errorMessage: String = ""
    
    private let path: String
    
    public init(path: String) {
        self.path = path
    }
    
    func body(content: Content) -> some View {
        content
            .environment(\.firebaseSignInWithEmailAndPassword, controller)
            .onAppear {
                controller.startListeningToAuthChanges(path: path)
            }
            .onDisappear {
                controller.stopListeningToAuthChanges()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name.firebaseSignInWithEmailAndPasswordError)) { notification in
                guard let object = notification.object as? String else { return }
                errorMessage = object
                isErrorAlertPresented = true
            }
            .alert("Error", isPresented: $isErrorAlertPresented) {
                Button("OK") {
                    errorMessage = ""
                }
            } message: {
                Text(errorMessage)
            }

    }
}

public extension View {
    /// Sets up FirebaseSignInWithEmailAndPassword and the collection path to the user documents in Firestore. Put this onto the root of your app
    /// - Parameter path: the collection path to the user documents in Firestore
    func configureFirebaseSignInWithEmailAndPasswordWith(firestoreUserCollectionPath path: String) -> some View {
        modifier(FirestoreUserCollectionPathModifier(path: path))
    }
}
