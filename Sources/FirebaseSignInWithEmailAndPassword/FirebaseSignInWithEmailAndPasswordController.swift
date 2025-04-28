//
//  FirebaseSignInWithEmailAndPasswordController.swift
//  FirebaseSignInWithEmailAndPassword
//
//  Created by Alex Nagy on 28.04.2025.
//

import SwiftUI
@preconcurrency import FirebaseAuth
import FirebaseFirestore

@MainActor
@Observable
final public class FirebaseSignInWithEmailAndPasswordController {
    
    // MARK: Public
    
    public var state: FirebaseSignInWithEmailAndPasswordAuthState = .loading
    public var previousState: FirebaseSignInWithEmailAndPasswordAuthState = .loading
    public var user: User?
    
    /// Authenticates the user into Firebase Authentication with Sign in with email and password.
    public func authenticate(email: String, password: String) async {
        do {
            try await authenticateFirebaseUser(email: email, password: password)
        } catch {
            NotificationCenter.post(error: error)
        }
    }
    
    /// Signs out the current user from Firebase Authentication.
    public func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            NotificationCenter.post(error: error)
        }
    }
    
    /// Deletes the current user from Firebase Authentication.
    /// Make sure you remove all data associated to the user with this extension: https://extensions.dev/extensions/firebase/delete-user-data
    public func deleteAccount(password: String) async {
        do {
            guard let user = Auth.auth().currentUser else {
                throw FirebaseSignInWithEmailAndPasswordError.noCurrentUser
            }
            guard let lastAuthenticationDate = user.metadata.lastSignInDate else {
                throw FirebaseSignInWithEmailAndPasswordError.noCurrentUserLastSignInDate
            }
            let needsReauthentication = !lastAuthenticationDate.isWithinPast(minutes: FirebaseSignInWithEmailAndPasswordConstants.reauthenticationIsRequiredAfterMinutes)
            
            if needsReauthentication {
                try await reauthenticate(user, password: password)
                try await deleteFirebaseAccount()
            } else {
                try await deleteFirebaseAccount()
            }
        } catch {
            NotificationCenter.post(error: error)
        }
    }
    
    // MARK: - Internal
    
    @discardableResult
    func createFirebaseUser(email: String, password: String) async throws -> AuthDataResult {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    @discardableResult
    func authenticateFirebaseUser(email: String, password: String) async throws -> AuthDataResult? {
        do {
            return try await Auth.auth().signIn(withEmail: email, password: password)
        } catch {
            if let error = error as NSError?, let code = AuthErrorCode(rawValue: error.code) {
                if code == .invalidCredential {
                    return try await createFirebaseUser(email: email, password: password)
                } else {
                    throw error
                }
            } else {
                throw error
            }
        }
    }
    
    func deleteFirebaseAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw FirebaseSignInWithEmailAndPasswordError.noCurrentUser
        }
        try await user.delete()
        state = .notAuthenticated
    }
    
    func startListeningToAuthChanges(path: String) {
        authStateHandler = Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
            if let user {
                self.saveProfileIfNeeded(user, path: path)
            } else {
                self.state = .notAuthenticated
            }
        }
    }
    
    func stopListeningToAuthChanges() {
        guard authStateHandler != nil else { return }
        Auth.auth().removeStateDidChangeListener(authStateHandler!)
    }
    
    // MARK: Private
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    private func saveProfileIfNeeded(_ user: User, path: String) {
        Task {
            do {
                let isUserAlreadyInFirestore = try await FirebaseSignInWithEmailAndPasswordUtils.isUserAlreadyInFirestore(path: path, uid: user.uid)
                if isUserAlreadyInFirestore {
                    self.state = .authenticated
                } else {
                    try await saveProfile(user, path: path)
                    try await Task.sleep(for: .seconds(1), tolerance: .seconds(1))
                    self.state = .authenticated
                }
            } catch {
                self.state = .notAuthenticated
                NotificationCenter.post(error: error)
            }
        }
    }
    
    private func saveProfile(_ user: User, path: String) async throws {
        let reference = Firestore.firestore().collection(path).document(user.uid)
        try await reference.setData([FirebaseSignInWithEmailAndPasswordConstants.userIdKey : user.uid])
    }
    
    @discardableResult
    private func reauthenticate(_ user: User, password: String) async throws -> AuthDataResult {
        let credential = EmailAuthProvider.credential(withEmail: user.email!, password: password)
        return try await user.reauthenticate(with: credential)
    }
}
