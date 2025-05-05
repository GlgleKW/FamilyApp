//
//  AddBillViewController.swift
//  FamilyApp
//
//  Created by Glgle Abdulghafoor on 28/04/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AddBillViewController: UIViewController {
    
    @IBOutlet weak var billName: UITextField!
    
    @IBOutlet weak var memberMenuButton: UIButton!
    
    @IBOutlet weak var selectedMembersStackView: UIStackView!
    
    @IBOutlet weak var splitBtn: UIButton!
    @IBOutlet weak var totalBillTF: UITextField!
    
    var amountFields: [UITextField] = []
    var selectedNames: [String] = []
    var membersID: [String] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        memberMenuButton.showsMenuAsPrimaryAction = true
        memberMenuButton.changesSelectionAsPrimaryAction = false
        
        loadFamilyMembersMenu()
        
        
    }
    
    
    
    func loadFamilyMembersMenu() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No user signed in.")
            return
        }
        
        let db = Firestore.firestore()
        
        // First get the current user's familyId
        db.collection("users").document(currentUser.uid).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching current user: \(error.localizedDescription)")
                return
            }
            
            guard let data = snapshot?.data(),
                  let familyId = data["familyId"] as? String else {
                print("No familyId found for user.")
                return
            }
            
            // Now fetch all users in the same family
            db.collection("users").whereField("familyId", isEqualTo: familyId).getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching family members: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No members found.")
                    return
                }
                
                let menuItems: [UIAction] = documents.compactMap { doc in
                    let data = doc.data()
                    let firstName = data["firstName"] as? String ?? ""
                    let lastName = data["lastName"] as? String ?? ""
                    let fullName = "\(firstName) \(lastName)"
                    let memberID = data["uid"] as? String ?? ""
                    
                    return UIAction(title: fullName, handler: { _ in
                        print("Selected: \(fullName)")
                        self.addMemberRow(name: fullName, mID: memberID)
                    })
                }
                
                DispatchQueue.main.async {
                    self.memberMenuButton.menu = UIMenu(title: "Family Members", children: menuItems)
                }
            }
        }
    }
    
    func addMemberRow(name: String, mID: String) {
        let horizontalStack = UIStackView()
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 8
        horizontalStack.alignment = .center
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        let amountField = UITextField()
        amountField.placeholder = "Amount"
        amountField.borderStyle = .roundedRect
        amountField.keyboardType = .decimalPad
        amountField.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        let removeButton = UIButton(type: .system)
        removeButton.setTitle("❌", for: .normal)
        removeButton.addTarget(self, action: #selector(removeRow(_:)), for: .touchUpInside)
        
        horizontalStack.addArrangedSubview(nameLabel)
        horizontalStack.addArrangedSubview(amountField)
        horizontalStack.addArrangedSubview(removeButton)
        
        selectedMembersStackView.addArrangedSubview(horizontalStack)
        amountFields.append(amountField)
        self.selectedNames.append(name)
        self.membersID.append(mID)

    }
    
    // 🔽 Put this inside the class
    @objc func removeRow(_ sender: UIButton) {
            if let rowStack = sender.superview as? UIStackView,
               let index = selectedMembersStackView.arrangedSubviews.firstIndex(of: rowStack) {

                // Also remove corresponding amountField
                amountFields.remove(at: index)
                selectedMembersStackView.removeArrangedSubview(rowStack)
                rowStack.removeFromSuperview()
                self.selectedNames.remove(at: index)
                self.membersID.remove(at: index)
            }
        }
    
    @IBAction func splitButtonPressed(_ sender: UIButton) {
        
        guard let totalText = totalBillTF.text,
                      let totalAmount = Double(totalText),
                      amountFields.count > 0 else {
                    print("Invalid total or no members")
                    return
                }

                let perPerson = totalAmount / Double(amountFields.count)

                for field in amountFields {
                    field.text = String(format: "%.2f", perPerson)
                }
        
    }
    
    @IBAction func addBillPressed(_ sender: UIButton) {
        
        guard
                let billTitle = billName.text, !billTitle.isEmpty,
                let totalText = totalBillTF.text, let totalAmount = Double(totalText)
            else {
                print("Missing data")
                return
            }

            Task {
                do {
                    let creatorName = try await UserService.shared.getCurrentUserFullName()
                    var members: [Bill.Member] = []

                    for (index, name) in selectedNames.enumerated() {
                        guard index < amountFields.count,
                              let amountText = amountFields[index].text,
                              let amount = Double(amountText) else {
                            continue
                        }
                        members.append(Bill.Member(name: name, amount: amount, hasPaid: false, mID: membersID[index]))
                    }

                    let bill = Bill(
                        id: "",
                        creatorName: creatorName,
                        billName: billTitle,
                        totalAmount: totalAmount,
                        createdAt: Date(),
                        members: members
                    )

                    let db = Firestore.firestore()
                    try await db.collection("bills").addDocument(data: bill.toDict())

                    print("Bill saved!")
                    self.navigationController?.popViewController(animated: true)

                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
    }
    
    
    
}
    
    

