//
//  MainViewController.swift
//  FamilyApp
//
//  Created by Glgle Abdulghafoor on 27/04/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController {
    
    var familyId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Family Manager"
        navigationItem.hidesBackButton = true
        
    }
    
    @IBOutlet weak var SEImage: UIImageView!
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
    
    @IBAction func inviteBtnPressed(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "homeToFamilyDetails", sender: self)
    }
    
    

    
    
    
    
    

}
