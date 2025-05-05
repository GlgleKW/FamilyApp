//
//  WelcomeViewController.swift
//  FamilyApp
//
//  Created by Glgle Abdulghafoor on 27/04/2025.
//

import UIKit
import FirebaseAuth

class WelcomeViewController: UIViewController {
    
    
    @IBOutlet weak var createFamilyBtn: UIButton!
    @IBOutlet weak var joinFamilyBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Family Manager"
        navigationItem.hidesBackButton = true

    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
