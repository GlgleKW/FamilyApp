//
//  MainViewController.swift
//  FamilyApp
//
//  Created by Glgle Abdulghafoor on 27/04/2025.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var signUpBtn: UIButton!
    
    @IBOutlet weak var logInBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        signUpBtn.layer.cornerRadius = 25
        signUpBtn.clipsToBounds = true
        
        logInBtn.layer.cornerRadius = 20
        logInBtn.clipsToBounds = true
    }
    

}
