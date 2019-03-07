//
//  AddPatientVC.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 11/17/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import CoreData

protocol EditingPatientDelegate: class{
  func didEditPatient(_ patient: Patient)
}

class AddPatientVC: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var addressField: SkyFloatingLabelTextField!
  @IBOutlet weak var phoneField: SkyFloatingLabelTextField!
  @IBOutlet weak var genderSwitch: UISwitch!
  @IBOutlet weak var birthField: SkyFloatingLabelTextField!
  @IBOutlet weak var nameField: SkyFloatingLabelTextField!
  
  private let container = AppDelegate.persistentContainer
  lazy var picker = UIDatePicker()
  private var chosenDate: Date?
  
  weak var delegate: EditingPatientDelegate!  
  var patientToEdit: Patient?
  private var theManager: Manager?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    recieveEditedPatient()
    getManager()
  }
  
  private func setupView() {
    nameField.delegate = self
    birthField.delegate = self
    phoneField.delegate = self
    createDateTimePicker(forField: birthField,withPicker: picker,selector: #selector(doneWithDateTime))
    birthField.inputView = picker
    let rightButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneClicked))
    navigationItem.rightBarButtonItem = rightButton
  }
  
  private func recieveEditedPatient() {
    guard patientToEdit != nil else {return}
    nameField.text = patientToEdit?.name
    birthField.text = DateFormatter.localizedString(from: (patientToEdit?.birth)!, dateStyle: .medium, timeStyle: .none)
    phoneField.text = patientToEdit?.phone
    addressField.text = patientToEdit?.address ?? ""
    genderSwitch.isOn = (patientToEdit?.gender == "Male")
  }
  
  fileprivate func getManager() {
    let context = container.viewContext
    if let manager = Manager.getManagerForDate(date: Date(), context: context) {
      theManager = manager
    }
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
        if name != nil && name != self.patientToEdit?.name {
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
    view.endEditing(true)
    let context = patientToEdit?.managedObjectContext ?? container.viewContext
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
    let patient = patientToEdit != nil ? patientToEdit : Patient(context: context)
    patient?.name = nameField.text
    patient?.birth = chosenDate ?? patient?.birth
    patient?.gender = gender
    patient?.phone = phoneField.text!
    patient?.address = addressField.text!
    if patientToEdit == nil {
      patient?.date = Date()
      patient?.status = 1
      theManager?.income?.patientsNumber += 1
      let history = MedicalHistory(context: context)
      history.thePatinet = patient
    }
    do {
      try context.save()
      if delegate != nil {
        delegate?.didEditPatient(patientToEdit!)
      }
      navigationController?.popViewController(animated: true)
    } catch {
      print(error)
    }
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
