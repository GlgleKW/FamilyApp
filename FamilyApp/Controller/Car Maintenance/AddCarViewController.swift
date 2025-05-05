//
//  AddCarViewController.swift
//  FamilyApp
//
//  Created by Glgle Abdulghafoor on 30/04/2025.
//

import UIKit
import Foundation
import FirebaseFirestore

class AddCarViewController: UIViewController {
    
    private var selectedDate: Date = Date()

    @IBOutlet weak var dateTF: UITextField!
    @IBOutlet weak var carNameTF: UITextField!
    @IBOutlet weak var ownerNameTF: UITextField!
    @IBOutlet weak var odometerTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let datepicker = UIDatePicker()
        datepicker.datePickerMode = .date
        datepicker.addTarget(self, action: #selector(dateChanged), for: UIControl.Event.valueChanged)
        datepicker.frame.size = CGSize(width: 0, height: 300)
        datepicker.preferredDatePickerStyle = .wheels
        
        dateTF.inputView = datepicker
        dateTF.text = formatDate(date: Date())
    }
    
    @objc func dateChanged(datePicker: UIDatePicker) {
        selectedDate = datePicker.date               // ✅ Save the selected date
        dateTF.text = formatDate(date: selectedDate)
    }

    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    
    @IBAction func addCarButtonPressed(_ sender: UIButton) {
        guard let carName = carNameTF.text, !carName.isEmpty,
                      let ownerName = ownerNameTF.text, !ownerName.isEmpty,
                      let odometerText = odometerTF.text, let odometer = Int(odometerText) else {
                    print("Missing or invalid input")
                    return
                }

                let carData: [String: Any] = [
                    "carId": UUID().uuidString,
                    "carName": carName,
                    "ownerName": ownerName,
                    "insuranceExpiry": Timestamp(date: selectedDate),
                    "nextServiceOdometer": odometer
                ]

                Firestore.firestore().collection("carMaintenance").addDocument(data: carData) { error in
                    if let error = error {
                        print("Failed to save car: \(error.localizedDescription)")
                    } else {
                        print("Car saved successfully")
                        NotificationCenter.default.post(name: Notification.Name("CarListUpdated"), object: nil)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
    }
    
}
