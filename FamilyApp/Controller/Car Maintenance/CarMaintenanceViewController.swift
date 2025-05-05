//
//  CarMaintenanceViewController.swift
//  FamilyApp
//
//  Created by Glgle Abdulghafoor on 30/04/2025.
//

import UIKit
import FirebaseFirestore

class CarMaintenanceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var cars: [CarMaintenance] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCarList), name: Notification.Name("CarListUpdated"), object: nil)

        title = "Car Maintenance"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        loadCars()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCars() // Refresh data when view appears
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("CarListUpdated"), object: nil)
    }

    
    func loadCars() {
        Firestore.firestore().collection("carMaintenance").getDocuments { snapshot, error in
            if let error = error {
                print("Error loading cars: \(error.localizedDescription)")
                return
            }
            guard let docs = snapshot?.documents else { return }
            self.cars = docs.compactMap { CarMaintenance.fromDocument($0) }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func reloadCarList() {
        loadCars()
    }

    // MARK: - Table View

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath) as? CarCell else {
            return UITableViewCell()
        }

        let car = cars[indexPath.row]
        cell.carNameLabel.text = car.carName
        cell.ownerNameLabel.text = car.ownerName
        cell.odometerLabel.text = "\(car.nextServiceOdometer) km"

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        cell.insuranceLabel.text = "\(formatter.string(from: car.insuranceExpiry))"
        
        // Remove any existing targets to prevent duplicates
        cell.moreButton.removeTarget(nil, action: nil, for: .allEvents)
        
        // Tag the button for later use
        cell.moreButton.tag = indexPath.row
        cell.moreButton.addTarget(self, action: #selector(modifyCarButtonPressed(_:)), for: .touchUpInside)

        return cell
    }
    
    @objc func modifyCarButtonPressed(_ sender: UIButton) {
        let index = sender.tag
        guard index < cars.count else { return }
        
        let selectedCar = cars[index]
        
        // Create the controller manually
        let editVC = EditCarViewController()
        
        // Load the view from the storyboard if needed
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "EditCarViewController") as? EditCarViewController {
            
            // Configure before showing
            viewController.car = selectedCar
            viewController.modalPresentationStyle = .fullScreen
            
            // Create custom done button
            let doneButton = UIBarButtonItem(
                barButtonSystemItem: .close,
                target: self,
                action: #selector(dismissModalController)
            )
            viewController.navigationItem.leftBarButtonItem = doneButton
            
            // Wrap in navigation controller
            let navController = UINavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .fullScreen
            
            // Present modally
            present(navController, animated: true)
        }
    }
    
    @objc func dismissModalController() {
        dismiss(animated: true)
    }
}
