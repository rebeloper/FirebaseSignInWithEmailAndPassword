//
//  FirebaseSignInWithEmailAndPasswordUtils.swift
//  FirebaseSignInWithEmailAndPassword
//
//  Created by Alex Nagy on 28.04.2025.
//

import FirebaseAuth
import FirebaseFirestore

struct FirebaseSignInWithEmailAndPasswordUtils {
    
    static func isUserAlreadyInFirestore(path: String, uid: String) async throws -> Bool {
        do {
            let reference = Firestore.firestore().collection(path)
            let snapshot = try await reference.document(uid).getDocument()
            return snapshot.exists
        } catch {
            if let error = error as NSError?, let code = FirestoreErrorCode.Code(rawValue: error.code) {
                if code == .notFound {
                    return false
                } else {
                    throw error
                }
            } else {
                throw error
            }
        }
    }
}
