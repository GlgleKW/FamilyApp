//
//  EditCarViewController.swift
//  FamilyApp
//
//  Created by Glgle Abdulghafoor on 30/04/2025.
//

import UIKit
import FirebaseFirestore

class EditCarViewController: UIViewController {
    
    // MARK: - Properties
    var car: CarMaintenance?
    
    private var selectedDate: Date = Date()
    private var loadingComplete = false
    
    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var carNameTF: UITextField!
    @IBOutlet weak var ownerNameTF: UITextField!
    @IBOutlet weak var odometerTF: UITextField!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Car Details"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Only setup once
        if !loadingComplete {
            setupCarData()
            loadingComplete = true
        }
    }
    
    // Deselect text field when tapping elsewhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Private Methods
    private func setupCarData() {
        guard let car = car,
              let dateTF = dateTF,
              let carNameTF = carNameTF,
              let ownerNameTF = ownerNameTF,
              let odometerTF = odometerTF else {
            print("Car or UI elements not available")
            return
        }
        
        // Add text field delegates
        dateTF.delegate = self
        carNameTF.delegate = self
        ownerNameTF.delegate = self
        odometerTF.delegate = self
        
        // Setup date picker
        configureDatePicker(car: car)
        
        // Populate fields
        carNameTF.text = car.carName
        ownerNameTF.text = car.ownerName
        odometerTF.text = String(car.nextServiceOdometer)
    }
    
    private func configureDatePicker(car: CarMaintenance) {
        let datepicker = UIDatePicker()
        datepicker.datePickerMode = .date
        datepicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        datepicker.frame.size = CGSize(width: 0, height: 300)
        datepicker.preferredDatePickerStyle = .wheels
        
        dateTF.inputView = datepicker
        selectedDate = car.insuranceExpiry
        dateTF.text = formatDate(date: selectedDate)
    }
    
    @objc private func dateChanged(datePicker: UIDatePicker) {
        selectedDate = datePicker.date
        dateTF.text = formatDate(date: selectedDate)
    }
    
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    // MARK: - Actions
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        guard let car = car,
              let carNameTF = carNameTF,
              let ownerNameTF = ownerNameTF,
              let odometerTF = odometerTF,
              let carName = carNameTF.text, !carName.isEmpty,
              let ownerName = ownerNameTF.text, !ownerName.isEmpty,
              let odometerText = odometerTF.text, let odometer = Int(odometerText) else {
            showAlert(title: "Invalid Input", message: "Please fill in all fields correctly")
            return
        }

        let updatedData: [String: Any] = [
            "carName": carName,
            "ownerName": ownerName,
            "nextServiceOdometer": odometer,
            "insuranceExpiry": Timestamp(date: selectedDate)
        ]

        Firestore.firestore().collection("carMaintenance").document(car.id).updateData(updatedData) { [weak self] error in
            if let error = error {
                self?.showAlert(title: "Error", message: "Failed to update car: \(error.localizedDescription)")
            } else {
                NotificationCenter.default.post(name: Notification.Name("CarListUpdated"), object: nil)
                self?.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        guard let car = car else { return }
        
        let alert = UIAlertController(
            title: "Delete Car",
            message: "Are you sure you want to delete this car?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            Firestore.firestore().collection("carMaintenance").document(car.id).delete { [weak self] error in
                if let error = error {
                    self?.showAlert(title: "Error", message: "Failed to delete car: \(error.localizedDescription)")
                } else {
                    NotificationCenter.default.post(name: Notification.Name("CarListUpdated"), object: nil)
                    self?.dismiss(animated: true)
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension EditCarViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
