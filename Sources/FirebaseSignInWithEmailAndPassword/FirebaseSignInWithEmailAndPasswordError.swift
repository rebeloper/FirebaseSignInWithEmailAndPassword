//
//  FirebaseSignInWithEmailAndPasswordError.swift
//  FirebaseSignInWithEmailAndPassword
//
//  Created by Alex Nagy on 28.04.2025.
//

import Foundation

public enum FirebaseSignInWithEmailAndPasswordError: Error {
    case noAuthDataResult
    case noCurrentUser
    case noCurrentUserLastSignInDate
}

extension FirebaseSignInWithEmailAndPasswordError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noAuthDataResult:
            return NSLocalizedString(
                "The Auth Data Result is missing.",
                comment: "No Auth Data Result"
            )
        case .noCurrentUser:
            return NSLocalizedString(
                "The Current User is missing.",
                comment: "No Current User"
            )
        case .noCurrentUserLastSignInDate:
            return NSLocalizedString(
                "The Current User Last Sign In Date is missing.",
                comment: "No Current User Last Sign In Date"
            )
        }
    }
}
