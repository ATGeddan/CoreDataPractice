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
  @IBOutlet weak var ageField: SkyFloatingLabelTextField!
  @IBOutlet weak var nameField: SkyFloatingLabelTextField!
  
  let container = AppDelegate.persistentContainer
  
  override func viewDidLoad() {
    super.viewDidLoad()
    phoneField.delegate = self
    ageField.delegate = self
    let rightButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneClicked))
    navigationItem.rightBarButtonItem = rightButton
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    textField.keyboardType = .numberPad
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
    return string.rangeOfCharacter(from: invalidCharacters) == nil
  }
  
  @objc private func doneClicked() {
    let context = container.viewContext
    guard nameField.text != "", ageField.text != "", phoneField.text != "" else {
      let alert = UIAlertController(title: "Not yet", message: "Please fill in all the recommended fields.", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
      present(alert,animated: true)
      return
    }
    let gender = genderSwitch.isOn ? "Male" : "Female"
    let patient = Patient(context: context)
    patient.name = nameField.text
    patient.age = Int32(ageField.text!)!
    patient.gender = gender
    patient.phone = Int32(phoneField.text!)!
    patient.address = addressField.text!
    try? context.save()
    navigationController?.popViewController(animated: true)
  }
  
}
