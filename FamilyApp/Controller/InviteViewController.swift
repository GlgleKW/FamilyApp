//
//  InviteViewController.swift
//  FamilyApp
//
//  Created by Glgle Abdulghafoor on 27/04/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class InviteViewController: UIViewController {
    
    
    @IBOutlet weak var familyNameLabel: UILabel!
    @IBOutlet weak var joinCodeLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var createdByLabel: UILabel!
    
    let db = Firestore.firestore()
    
    var familyId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadFamilyDetails()
        
    }
    
    func loadFamilyDetails() {
        UserService.shared.getCurrentUserFamilyId { familyId in
            guard let familyId = familyId else {
                print("No family ID found for user.")
                return
            }

            let db = Firestore.firestore()
            db.collection("families").document(familyId).getDocument { snapshot, error in
                if let error = error {
                    print("Error fetching family: \(error.localizedDescription)")
                    return
                }

                guard let data = snapshot?.data() else {
                    print("No family data found")
                    return
                }

                let familyName = data["familyName"] as? String ?? "N/A"
                let joinCode = data["joinCode"] as? Int ?? 0
                let ownerId = data["ownerId"] as? String ?? ""
                let createdAtTimestamp = data["createdAt"] as? Timestamp
                let createdAtDate = createdAtTimestamp?.dateValue()

                Task {
                    do {
                        let ownerFullName = try await UserService.shared.getFullName(forUserId: ownerId)

                        DispatchQueue.main.async {
                            self.familyNameLabel.text = familyName
                            self.joinCodeLabel.text = "\(joinCode)"
                            self.createdByLabel.text = ownerFullName

                            if let date = createdAtDate {
                                let formatter = DateFormatter()
                                formatter.dateStyle = .medium
                                formatter.timeStyle = .short
                                self.createdAtLabel.text = formatter.string(from: date)
                            } else {
                                self.createdAtLabel.text = "N/A"
                            }
                        }

                    } catch {
                        print("Failed to get owner's full name: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}



    
    
    
    


