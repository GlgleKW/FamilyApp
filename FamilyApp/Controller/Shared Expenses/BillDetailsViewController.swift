//
//  BillDetailsViewController.swift
//  FamilyApp
//
//  Created by Glgle Abdulghafoor on 29/04/2025.
//

import UIKit
import FirebaseFirestore

class BillDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var bill: Bill?
    
    @IBOutlet weak var billNameLabel: UILabel!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var membersTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        membersTableView.delegate = self
                membersTableView.dataSource = self
        
        if let bill = bill {
                    billNameLabel.text = bill.billName
                    totalAmountLabel.text = String(format: "$%.2f", bill.totalAmount)
                    creatorNameLabel.text = "Created by: \(bill.creatorName)"
                    
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    formatter.timeStyle = .short
                    createdAtLabel.text = formatter.string(from: bill.createdAt)
            
                    membersTableView.reloadData()
                }
        
        print("Loaded members: \(bill?.members.count ?? -1)")

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return bill?.members.count ?? 0
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as? MemberTableViewCell,
                let member = bill?.members[indexPath.row]
            else {
                return UITableViewCell()
            }

            cell.memberNameLabel.text = member.name
            cell.amountLabel.text = "$\(String(format: "%.2f", member.amount))"
            cell.paidSwitch.isOn = member.hasPaid

            // Set a tag to identify the switch
            cell.paidSwitch.tag = indexPath.row
            cell.paidSwitch.addTarget(self, action: #selector(paidSwitchChanged(_:)), for: .valueChanged)

            return cell
        }
    
    @objc func paidSwitchChanged(_ sender: UISwitch) {
        let index = sender.tag
        guard var bill = bill else { return }

        // Update local state
        bill.members[index].hasPaid = sender.isOn
        self.bill = bill // update the view's reference

        // Update in Firestore
        let db = Firestore.firestore()

        // Create updated member dictionary
        let updatedMember = bill.members[index].toDict()

        // Replace the member at that index in Firestore
        var updatedMembers = bill.members.map { $0.toDict() }

        db.collection("bills").document(bill.id).updateData([
            "members": updatedMembers
        ]) { error in
            if let error = error {
                print("Error updating member: \(error.localizedDescription)")
            } else {
                print("Updated hasPaid for \(bill.members[index].name) to \(sender.isOn)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadBillFromFirestore()
    }

    
    func reloadBillFromFirestore() {
        guard let billId = bill?.id else { return }

        let db = Firestore.firestore()
        db.collection("bills").document(billId).getDocument { snapshot, error in
            if let error = error {
                print("Error reloading bill: \(error.localizedDescription)")
                return
            }

            guard let data = snapshot?.data() else {
                print("No bill data found")
                return
            }

            // Parse the bill again from Firestore
            guard let billName = data["billName"] as? String,
                  let creatorName = data["creatorName"] as? String,
                  let totalAmount = data["totalAmount"] as? Double,
                  let createdAtTimestamp = data["createdAt"] as? Timestamp,
                  let memberDicts = data["members"] as? [[String: Any]] else {
                print("Invalid bill structure")
                return
            }

            let members: [Bill.Member] = memberDicts.compactMap { dict in
                guard let name = dict["name"] as? String,
                      let amount = dict["amount"] as? Double,
                      let hasPaid = dict["hasPaid"] as? Bool,
                      let mID = dict["mID"] as? String else {
                    return nil
                }

                return Bill.Member(name: name, amount: amount, hasPaid: hasPaid, mID: mID)
            }

            self.bill = Bill(
                id: billId,
                creatorName: creatorName,
                billName: billName,
                totalAmount: totalAmount,
                createdAt: createdAtTimestamp.dateValue(),
                members: members
            )

            DispatchQueue.main.async {
                self.membersTableView.reloadData()
            }
        }
    }

}
