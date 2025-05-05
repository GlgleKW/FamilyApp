//
//  LogInViewController.swift
//  FamilyApp
//
//  Created by Glgle Abdulghafoor on 27/04/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LogInViewController: UIViewController {
    
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBAction func loginPressed(_ sender: UIButton) {
        
        if let email = emailTF.text, let password = passwordTF.text {
            Auth.auth().signIn(withEmail: email, password: password) {authResult, error in
              if let e = error {
                    print(e)
                } else {
                    if let currentUser = Auth.auth().currentUser{
                        self.checkIfUserIsInFamily(userId: currentUser.uid)
                    }
                    
              }
            }
        }
        
    }
    
    
    func checkIfUserIsInFamily(userId: String) {
            let db = Firestore.firestore()
            
            // Query Firestore to check if the user is in any family
            db.collection("families").whereField("members", arrayContains: userId).getDocuments { snapshot, error in
                if let error = error {
                    print("Error checking user's family: \(error.localizedDescription)")
                    return
                }
                
                // If a family is found with this user, navigate to HomeViewController
                if let snapshot = snapshot, !snapshot.isEmpty {
                    print("User is part of a family.")
                    self.performSegue(withIdentifier: "LoginToHome", sender: self)
                } else {
                    print("User is not part of any family.")
                    self.performSegue(withIdentifier: "LoginToWelcome", sender: self)
                }
            }
        }


}
