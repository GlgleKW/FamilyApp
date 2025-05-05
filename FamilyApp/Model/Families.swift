import Foundation
import FirebaseFirestore

struct Family {
    var familyName: String
    var ownerId: String
    var members: [String]
    var createdAt: Date
    var joinCode: Int
    
    init(familyName: String, ownerId: String, members: [String], createdAt: Date, joinCode: Int) {
        self.familyName = familyName
        self.ownerId = ownerId
        self.members = members
        self.createdAt = createdAt
        self.joinCode = joinCode
    }
    
    func toFirestore() -> [String: Any] {
        return [
            "familyName": self.familyName,
            "ownerId": self.ownerId,
            "members": self.members,
            "createdAt": Timestamp(date: self.createdAt),
            "joinCode": self.joinCode
        ]
    }
}
