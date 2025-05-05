import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserService {
    
    static let shared = UserService()
    private init() {} // prevents others from creating another instance
    
    private let db = Firestore.firestore()
    
    // Public function to save or update a user profile
    func saveUserProfile(firstName: String, lastName: String, familyId: String, completion: ((Error?) -> Void)? = nil) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is signed in")
            completion?(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user is signed in"]))
            return
        }
        
        let email = currentUser.email ?? ""

        let user = Users(uid: currentUser.uid, email: email, firstName: firstName, lastName: lastName, familyId: familyId)

        db.collection("users").document(currentUser.uid).setData(user.toFirestore()) { error in
            if let error = error {
                print("Error saving user profile: \(error.localizedDescription)")
                completion?(error)
            } else {
                print("User profile saved successfully!")
                completion?(nil)
            }
        }
    }
    
    func saveFamilyIDtoUser(familyId: String, completion: ((Error?) -> Void)? = nil) {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is signed in")
            completion?(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user is signed in"]))
            return
        }
        
        db.collection("users").document(currentUser.uid).updateData(["familyId": familyId]) { error in
            if let error = error {
                print("Error saving family ID to user: \(error.localizedDescription)")
                completion?(error)
            } else {
                print("Family ID saved to user successfully!")
                completion?(nil)
            }
        }
    }

    
    func getCurrentUserFamilyId(completion: @escaping (String?) -> Void) {
            guard let uid = Auth.auth().currentUser?.uid else {
                print("hi")
                completion(nil)
                return
            }

            let db = Firestore.firestore()
            db.collection("users").document(uid).getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching user data: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                if let data = snapshot?.data(), let familyId = data["familyId"] as? String {
                    completion(familyId)
                } else {
                    completion(nil)
                }
            }
        }
    
    func getCurrentUserFullName() async throws -> String {
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user is signed in"])
        }

        let docRef = db.collection("users").document(currentUser.uid)
        let document = try await docRef.getDocument()

        guard let data = document.data(),
              let firstName = data["firstName"] as? String,
              let lastName = data["lastName"] as? String else {
            throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User name fields not found"])
        }

        return "\(firstName) \(lastName)"
    }
    
    func getFullName(forUserId uid: String) async throws -> String {
        let db = Firestore.firestore()
        let userDoc = try await db.collection("users").document(uid).getDocument()

        guard let data = userDoc.data() else {
            throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }

        let firstName = data["firstName"] as? String ?? ""
        let lastName = data["lastName"] as? String ?? ""

        return "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }


}
