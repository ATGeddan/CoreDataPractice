//
//  AddPatientVC.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 11/17/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import CoreData

class AddPatientVC: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var addressField: SkyFloatingLabelTextField!
  @IBOutlet weak var phoneField: SkyFloatingLabelTextField!
  @IBOutlet weak var genderSwitch: UISwitch!
  @IBOutlet weak var birthField: SkyFloatingLabelTextField!
  @IBOutlet weak var nameField: SkyFloatingLabelTextField!
  
  let container = AppDelegate.persistentContainer
  lazy var picker = UIDatePicker()
  private var chosenDate: Date?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    nameField.delegate = self
    birthField.delegate = self
    phoneField.delegate = self
    createDateTimePicker()
    birthField.inputView = picker
    let rightButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneClicked))
    navigationItem.rightBarButtonItem = rightButton
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    let field = textField as? SkyFloatingLabelTextField
    field?.errorMessage = nil
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    switch textField.tag {
    case 1:
      guard !(textField.text?.isEmpty)! else {return}
      checkIfExists {[unowned self] (name) in
        // Use the name to go back and search
        if let theName = name {
          print(theName) // Placeholder
          self.nameField.errorMessage = "This patient already exists!"
        }
      }
    case 2:
      guard !(birthField.text?.isEmpty)! else {
        birthField.errorMessage = "Birth Date is required!"
        return
      }
    case 3:
      guard !(phoneField.text?.isEmpty)! else {return}
      guard (phoneField.text?.count)! >= 10 else {
        phoneField.errorMessage = "Invalid Phone number!"
        return
      }
    default:
      break
    }
  }
  
  private func checkIfExists(completion: @escaping (_ name:String?)->Void)  {
    let request: NSFetchRequest<Patient> = Patient.fetchRequest()
    request.predicate = NSPredicate(format: "name like[c] %@", nameField.text!)
    do {
      let results = try container.viewContext.fetch(request)
      if !results.isEmpty {
        completion(results.first?.name)
      } else {
        completion(nil)
      }
    } catch {
      print(error)
      completion(nil)
    }
  }
  
  @objc private func doneClicked() {
    let context = container.viewContext
    guard nameField.text != "", birthField.text != "", phoneField.text != "" else {
      presentBasicAlert(title: "Not yet", message: "Please fill in all the recommended fields.")
      return
    }
    guard (phoneField.text?.count)! >= 10 else {
      presentBasicAlert(title: "Invalid Number", message: "Please make sure you have the correct phone number.")
      return
    }
    guard nameField.errorMessage == nil else {
      presentBasicAlert(title: "Patient exists", message: "Try to search for this patient, they might be an old friend.")
      return
    }
    let gender = genderSwitch.isOn ? "Male" : "Female"
    let patient = Patient(context: context)
    patient.name = nameField.text
    patient.birth = chosenDate
    patient.gender = gender
    patient.phone = phoneField.text!
    patient.address = addressField.text!
    patient.date = Date()
    patient.status = 1
    do {
      try context.save()
      navigationController?.popViewController(animated: true)
    } catch {
      print(error)
    }
  }
  
  private func createDateTimePicker() {
    let toolbar = UIToolbar()
    toolbar.sizeToFit()
    
    let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneWithDateTime))
    toolbar.setItems([done], animated: true)
    toolbar.tintColor = UIColor.darkGray
    birthField.inputAccessoryView = toolbar
    birthField.inputView = picker
    picker.datePickerMode = .date
  }
  
  @objc private func doneWithDateTime() {
    chosenDate = picker.date
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    let dateString = formatter.string(from: picker.date)
    birthField.text = dateString
    view.endEditing(true)
  }
  
}
