//
//  Users.swift
//  FamilyApp
//
//  Created by Glgle Abdulghafoor on 28/04/2025.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct Users {
    var uid: String
    var email: String
    var familyId: String?
    var firstName: String
    var lastName: String

    init(uid: String, email: String, firstName: String, lastName: String, familyId: String? = nil) {
        self.uid = uid
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.familyId = familyId
    }

    func toFirestore() -> [String: Any] {
        return [
            "uid": uid,
            "email": email,
            "firstName": firstName,
            "lastName": lastName,
            "familyId": familyId ?? NSNull()
        ]
    }
}
