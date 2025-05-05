//
//  BillTableViewController.swift
//  FamilyApp
//
//  Created by Glgle Abdulghafoor on 29/04/2025.
//

import UIKit
import FirebaseFirestore

class BillTableViewController: UITableViewController {
    
    var bills: [Bill] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableView.automaticDimension
            tableView.estimatedRowHeight = 80 // Just a guess, can be 100 too
        loadBills()
    }
    
    func loadBills() {
        let db = Firestore.firestore()
        db.collection("bills").order(by: "createdAt", descending: true).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching bills: \(error.localizedDescription)")
                return
            }

            guard let documents = snapshot?.documents else { return }

            self.bills = documents.compactMap { doc -> Bill? in
                let data = doc.data()

                
                guard let billName = data["billName"] as? String,
                      let creatorName = data["creatorName"] as? String,
                      let totalAmount = data["totalAmount"] as? Double,
                      let createdAtTimestamp = data["createdAt"] as? Timestamp else {
                    return nil
                }

                let memberDicts = data["members"] as? [[String: Any]] ?? []

                let members: [Bill.Member] = memberDicts.compactMap { dict in
                    guard let name = dict["name"] as? String,
                          let amount = dict["amount"] as? Double,
                          let hasPaid = dict["hasPaid"] as? Bool,
                          let mID = dict["mID"] as? String else {
                        return nil
                    }

                    return Bill.Member(name: name, amount: amount, hasPaid: hasPaid, mID: mID)
                }

                return Bill(
                    id: doc.documentID,
                    creatorName: creatorName,
                    billName: billName,
                    totalAmount: totalAmount,
                    createdAt: createdAtTimestamp.dateValue(),
                    members: members
                )
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }


    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return bills.count
        }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BillCell", for: indexPath) as? BillTableViewCell else {
            return UITableViewCell()
        }
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"

        let bill = bills[indexPath.row]
        let date = bill.createdAt
        let dateString = formatter.string(from: date)
        
        cell.billNameLabel.text = bill.billName
        //cell.amountLabel.text = "$\(String(format: "%.2f", bill.totalAmount))"
        cell.amountLabel.text = "\(bill.totalAmount) KD"
        cell.creatorNameLabel.text = "\(bill.creatorName)"
        cell.createdAtLabel.text = dateString

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBill = bills[indexPath.row]

        if let detailsVC = storyboard?.instantiateViewController(withIdentifier: "BillDetailsViewController") as? BillDetailsViewController {
            detailsVC.bill = selectedBill
            navigationController?.pushViewController(detailsVC, animated: true)
        }
    }

}
