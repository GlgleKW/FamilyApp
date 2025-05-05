//
//  GroceryListViewController.swift
//  FamilyApp
//
//  Created by Glgle Abdulghafoor on 30/04/2025.
//

import UIKit
import FirebaseFirestore

class GroceryListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Data
    var items: [GroceryItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadItems()
    }
    
    // MARK: - Load Items
    func loadItems() {
        Firestore.firestore().collection("groceryItems").getDocuments { snapshot, error in
            if let error = error {
                print("Error loading items: \(error.localizedDescription)")
                return
            }
            
            guard let docs = snapshot?.documents else { return }
            self.items = docs.compactMap { GroceryItem.fromDocument($0) }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Add Item

    @IBAction func addItemButtonPressed(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty,
              let amountText = amountTextField.text,
              let amount = Int(amountText) else {
            print("Invalid input")
            return
        }

        let newItemData: [String: Any] = [
            "name": name,
            "amount": amount,
            "isChecked": false
        ]

        Firestore.firestore().collection("groceryItems").addDocument(data: newItemData) { error in
            if let error = error {
                print("Error adding item: \(error.localizedDescription)")
            } else {
                self.nameTextField.text = ""
                self.amountTextField.text = ""
                self.loadItems()
            }
        }
    }
    

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroceryItemCell", for: indexPath) as? GroceryItemCell else {
            return UITableViewCell()
        }

        let item = items[indexPath.row]
        cell.nameLabel.text = item.name
        cell.amountLabel.text = "x\(item.amount)"
        cell.checkSwitch.isOn = item.isChecked

        // Configure actions
        cell.checkSwitch.tag = indexPath.row
        cell.checkSwitch.addTarget(self, action: #selector(didToggleSwitch(_:)), for: .valueChanged)

        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteItem(_:)), for: .touchUpInside)

        return cell
    }

    // MARK: - Toggle Check
    @objc func didToggleSwitch(_ sender: UISwitch) {
        let index = sender.tag
        let item = items[index]

        Firestore.firestore().collection("groceryItems").document(item.id).updateData([
            "isChecked": sender.isOn
        ]) { error in
            if let error = error {
                print("Error updating item: \(error.localizedDescription)")
            } else {
                self.items[index].isChecked = sender.isOn
            }
        }
    }

    // MARK: - Delete Item
    @objc func deleteItem(_ sender: UIButton) {
        let index = sender.tag
        let item = items[index]

        Firestore.firestore().collection("groceryItems").document(item.id).delete { error in
            if let error = error {
                print("Error deleting item: \(error.localizedDescription)")
            } else {
                self.items.remove(at: index)
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        }
    }
}
