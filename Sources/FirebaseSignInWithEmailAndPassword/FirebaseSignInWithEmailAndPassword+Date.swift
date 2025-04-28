//
//  FirebaseSignInWithEmailAndPassword+Date.swift
//  FirebaseSignInWithEmailAndPassword
//
//  Created by Alex Nagy on 28.04.2025.
//

import Foundation

extension Date {
    func isWithinPast(minutes: Int) -> Bool {
        let now = Date.now
        let timeAgo = Date.now.addingTimeInterval(-1 * TimeInterval(60 * minutes))
        let range = timeAgo...now
        return range.contains(self)
    }
}
