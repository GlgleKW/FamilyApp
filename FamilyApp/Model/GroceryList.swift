//
//  GroceryList.swift
//  FamilyApp
//
//  Created by Glgle Abdulghafoor on 30/04/2025.
//

import Foundation
import FirebaseFirestore

struct GroceryItem {
    let id: String       // Firestore document ID
    let name: String
    let amount: Int
    var isChecked: Bool

    // Convert to Firestore dictionary
    func toDict() -> [String: Any] {
        return [
            "name": name,
            "amount": amount,
            "isChecked": isChecked
        ]
    }

    // Create a GroceryItem from a Firestore document
    static func fromDocument(_ doc: DocumentSnapshot) -> GroceryItem? {
        let data = doc.data() ?? [:]

        guard let name = data["name"] as? String,
              let amount = data["amount"] as? Int,
              let isChecked = data["isChecked"] as? Bool
        else {
            return nil
        }

        return GroceryItem(
            id: doc.documentID,
            name: name,
            amount: amount,
            isChecked: isChecked
        )
    }
}
