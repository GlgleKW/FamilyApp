//
//  JoinFamilyViewController.swift
//  FamilyApp
//
//  Created by Glgle Abdulghafoor on 27/04/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class JoinFamilyViewController: UIViewController {
    
    
    @IBOutlet weak var joinCodeTF: UITextField!
    
    @IBOutlet weak var joinBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func JoinBtnPressed(_ sender: UIButton) {
        
        guard let joinCodeText = joinCodeTF.text, !joinCodeText.isEmpty else {
                    print("Join code is required")
                    return
                }

                guard let joinCode = Int(joinCodeText) else {
                    print("Invalid join code")
                    return
                }
                
                // Fetch the family with the given join code
                let db = Firestore.firestore()
                db.collection("families").whereField("joinCode", isEqualTo: joinCode).getDocuments { snapshot, error in
                    if let error = error {
                        print("Error finding family with join code: \(error.localizedDescription)")
                        return
                    }
                    
                    if snapshot!.isEmpty {
                        print("No family found with that join code")
                        return
                    }
                    
                    // We found the family, now we can add the user to the members array
                    let familyDocument = snapshot!.documents.first!
                    let familyId = familyDocument.documentID
                    var familyData = familyDocument.data()
                    var members = familyData["members"] as! [String]
                    
                    // Check if the user is already a member
                    guard let currentUser = Auth.auth().currentUser else {
                        print("No user is signed in")
                        return
                    }
                    
                    if members.contains(currentUser.uid) {
                        print("You are already a member of this family")
                        return
                    }

                    // Add the user to the members list
                    members.append(currentUser.uid)
                    familyData["members"] = members

                    // Update the Firestore document with the new members list
                    familyDocument.reference.updateData(["members": members]) { error in
                        if let error = error {
                            print("Error adding user to family: \(error.localizedDescription)")
                        } else {
                            print("User successfully joined the family!")
                            
                            UserService.shared.saveFamilyIDtoUser(familyId: familyId) { error in
                                if let error = error {
                                    print("Error updating user profile: \(error.localizedDescription)")
                                } else {
                                    print("User profile updated successfully!")
                                    self.performSegue(withIdentifier: "JoinToHome", sender: self)
                                }
                            }
                        }
                    }
                }
    }
    
}
