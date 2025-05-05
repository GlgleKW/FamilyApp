//
//  Cars.swift
//  FamilyApp
//
//  Created by Glgle Abdulghafoor on 30/04/2025.
//

import Foundation
import FirebaseFirestore

struct CarMaintenance {
    let id: String
    let carId: String
    let carName: String
    let ownerName: String
    let insuranceExpiry: Date
    let nextServiceOdometer: Int

    func toDict() -> [String: Any] {
        return [
            "carId": carId,
            "carName": carName,
            "ownerName": ownerName,
            "insuranceExpiry": Timestamp(date: insuranceExpiry),
            "nextServiceOdometer": nextServiceOdometer
        ]
    }

    static func fromDocument(_ doc: DocumentSnapshot) -> CarMaintenance? {
        let data = doc.data() ?? [:]

        guard let carId = data["carId"] as? String,
              let carName = data["carName"] as? String,
              let ownerName = data["ownerName"] as? String,
              let insuranceExpiry = data["insuranceExpiry"] as? Timestamp,
              let nextServiceOdometer = data["nextServiceOdometer"] as? Int else {
            return nil
        }

        return CarMaintenance(
            id: doc.documentID,
            carId: carId,
            carName: carName,
            ownerName: ownerName,
            insuranceExpiry: insuranceExpiry.dateValue(),
            nextServiceOdometer: nextServiceOdometer
        )
    }
}
