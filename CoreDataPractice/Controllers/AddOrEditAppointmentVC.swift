//
//  AddOrEditAppointmentVC.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 11/16/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import CoreData

class AddOrEditAppointmentVC: UIViewController, UITextViewDelegate {
  
  @IBOutlet weak var procedureView: UITextView!
  @IBOutlet weak var assistantField: SkyFloatingLabelTextField!
  @IBOutlet weak var operatorField: SkyFloatingLabelTextField!
  @IBOutlet weak var dateField: SkyFloatingLabelTextField!
  
  lazy var picker = UIDatePicker()
  var chosenDate: Date?
  var patient: Patient!
  var appointment: Appointment!
  var delegate: DidEditAppointmentDelegate!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    procedureView.delegate = self
    procedureView.layer.borderWidth = 1
    procedureView.layer.borderColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
    procedureView.layer.cornerRadius = 10
    procedureView.textColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
    
    let rightButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveAppointment))
    navigationItem.rightBarButtonItem = rightButton
    recieveAppointmentToEdit()
    createDateTimePicker()
  }
  
  private func recieveAppointmentToEdit() {
    if appointment != nil {
      dateField.text = DateFormatter.localizedString(from: appointment.date!, dateStyle: .medium, timeStyle: .short)
      chosenDate = appointment.date
      operatorField.text = appointment.theOperator
      assistantField.text = appointment.assistant ?? ""
      procedureView.text = appointment.procedure
    }
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.text == "Procedure ..." {
      textView.layer.borderColor = #colorLiteral(red: 0.7128025293, green: 0.5533084869, blue: 0.2515522838, alpha: 1)
      textView.text = ""
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.layer.borderColor = #colorLiteral(red: 0.07090329379, green: 0.1490469873, blue: 0.1254850328, alpha: 1)
      textView.text = "Procedure ..."
    }
  }
  
  @objc private func saveAppointment() {
    guard dateField.text != "" else {
      presentBasicAlert(title: "Date Missing", message: "Please set the date of the appointment.")
      return
    }
    guard operatorField.text != "" else {
      presentBasicAlert(title: "Operator Missing", message: "Please set the operator of the procedure.")
      return
    }
    guard procedureView.text != "Procedure ..." else {
      presentBasicAlert(title: "Procedure Missing", message: "Please clarify the procedure of the appointment.")
      return
    }
    var context: NSManagedObjectContext!
    if appointment == nil {
      context = patient.managedObjectContext
      appointment = Appointment(context: context)
      appointment.thePatient = patient
    } else {
      context = appointment.managedObjectContext
    }
    appointment.date = chosenDate
    appointment.theOperator = operatorField.text
    appointment.assistant = assistantField.text
    appointment.procedure = procedureView.text 
    let dateformatter = DateFormatter()
    dateformatter.dateFormat = "dd.MM.yy"
    appointment.comparisonDate = dateformatter.string(from: chosenDate!)
    appointment.id = UUID().uuidString
    do {
      try context.save()
      if delegate != nil {
        delegate.didEditAppointment(appointment)
      }
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
    dateField.inputAccessoryView = toolbar
    dateField.inputView = picker
    picker.datePickerMode = .dateAndTime
  }
  
  @objc private func doneWithDateTime() {
    chosenDate = picker.date
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    let dateString = formatter.string(from: picker.date)
    dateField.text = dateString
    view.endEditing(true)
  }
  
}
