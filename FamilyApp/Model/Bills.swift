//
//  Bills.swift
//  FamilyApp
//
//  Created by Glgle Abdulghafoor on 29/04/2025.
//

import Foundation
import FirebaseFirestore

struct Bill {
    let id: String
    let creatorName: String
    let billName: String
    let totalAmount: Double
    let createdAt: Date
    var members: [Member]

    struct Member {
        let name: String
        let amount: Double
        var hasPaid: Bool
        let mID: String
        
        func toDict() -> [String: Any] {
            return [
                "name": name,
                "amount": amount,
                "hasPaid": hasPaid,
                "mID": mID
            ]
        }
    }

    func toDict() -> [String: Any] {
        return [
            "creatorName": creatorName,
            "billName": billName,
            "totalAmount": totalAmount,
            "createdAt": Timestamp(date: createdAt),
            "members": members.map { $0.toDict() }
        ]
    }
}
