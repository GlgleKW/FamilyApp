//
//  CreateFamilyViewController.swift
//  FamilyApp
//
//  Created by Glgle Abdulghafoor on 27/04/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CreateFamilyViewController: UIViewController {
    
    
    @IBOutlet weak var FamilyNameTF: UITextField!
    @IBOutlet weak var CreateFamilyBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func CreateBtnPressed(_ sender: UIButton) {
        
        guard let familyName = FamilyNameTF.text, !familyName.isEmpty else {
            print("Family name is required")
            return
        }
        
        
        
        
        guard let currentUser = Auth.auth().currentUser else {
            print("No user is signed in")
            return
        }
        var joinCode = generateJoinCode()
        
        let db = Firestore.firestore()
        
        db.collection("families").whereField("joinCode", isEqualTo: joinCode).getDocuments { snapshot, error in
            if let error = error {
                print("Error checking join code: \(error.localizedDescription)")
                return
            }
            
            // If the join code exists, regenerate it
            if !snapshot!.isEmpty {
                print("Join code already exists, generating a new one...")
                joinCode = generateJoinCode()  // Regenerate and recheck
            } // This generates a 6-digit code
            
            let family = Family(
                familyName: familyName,
                ownerId: currentUser.uid,
                members: [currentUser.uid],
                createdAt: Date(),
                joinCode: joinCode
            )
            
            saveFamilyToFirestore(family)
        }
        
        // Function to save Family object to Firestore
        func saveFamilyToFirestore(_ family: Family) {
            let db = Firestore.firestore()
            let familyData = family.toFirestore()
            
            print("Uploading family data: \(familyData)")
            
            var ref: DocumentReference? = nil
            ref = db.collection("families").addDocument(data: familyData) { error in
                if let error = error {
                    print("Error creating family: \(error.localizedDescription)")
                } else {
                    if let familyId = ref?.documentID {
                        print("Family created successfully with ID: \(familyId)")
                        
                        // Save user profile with familyId
                        UserService.shared.saveFamilyIDtoUser(familyId: familyId) { error in
                            if let error = error {
                                print("Error updating user profile: \(error.localizedDescription)")
                            } else {
                                print("User profile updated successfully!")
                                self.performSegue(withIdentifier: "CreateToHome", sender: self)
                            }
                        }
                    }
                }
            }
            
            
            
        }
        
        func generateJoinCode() -> Int {
            // Create a random 6-digit number as a string
            let randomCode = Int.random(in: 100000...999999)
            return randomCode
        }
    }
    
}
