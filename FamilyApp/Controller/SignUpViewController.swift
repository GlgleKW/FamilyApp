//
//  SignUpViewController.swift
//  FamilyApp
//
//  Created by Glgle Abdulghafoor on 27/04/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    

    @IBAction func signupPressed(_ sender: UIButton) {
        if let email = emailTF.text, let password = passwordTF.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e)
                    return
                }
                guard let user = authResult?.user else { return }
                    let db = Firestore.firestore()

                    let userData: [String: Any] = [
                        "uid": user.uid,
                        "email": user.email ?? "",
                        "firstName": self.firstNameTF.text ?? "",
                        "lastName": self.lastNameTF.text ?? "",
                        "familyId": NSNull()  // initially no family
                    ]

                    db.collection("users").document(user.uid).setData(userData) { error in
                        if let error = error {
                            print("Error saving user data: \(error.localizedDescription)")
                        } else {
                            print("User profile saved successfully!")
                            // Navigate to home or welcome screen
                            self.performSegue(withIdentifier: "SignUpToWelcome", sender: self)
                        }
                    }
                }
        }
    }
    
    
}
    

