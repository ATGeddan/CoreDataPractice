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
  @IBOutlet weak var costField: SkyFloatingLabelTextField!
  
  lazy var picker = UIDatePicker()
  var chosenDate: Date?
  var patient: Patient!
  var appointmentToEdit: Appointment!
  var delegate: DidEditAppointmentDelegate!
  private var previousCost: Int32 = 0
  private var theManager: Manager?
  
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
    createDateTimePicker(forField: dateField,withPicker: picker, mode : .dateAndTime,selector: #selector(doneWithDateTime))
    getManager()
  }
  
  private func recieveAppointmentToEdit() {
    if appointmentToEdit != nil {
      dateField.text = DateFormatter.localizedString(from: appointmentToEdit.date!, dateStyle: .medium, timeStyle: .short)
      chosenDate = appointmentToEdit.date
      operatorField.text = appointmentToEdit.theOperator
      assistantField.text = appointmentToEdit.assistant ?? ""
      if appointmentToEdit.cost != 0 {
        costField.text = String(appointmentToEdit.cost)
        previousCost = appointmentToEdit.cost
      }
      procedureView.text = appointmentToEdit.procedure
    }
  }
  
  fileprivate func getManager() {
    let context = AppDelegate.context
    if let manager = Manager.getManagerForDate(date: Date(), context: context) {
      theManager = manager
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
    if appointmentToEdit == nil {
      context = AppDelegate.persistentContainer.viewContext
      appointmentToEdit = Appointment(context: context)
      appointmentToEdit.thePatient = patient
      appointmentToEdit.thePatient?.totalFees += Int32.parse(fromString: costField.text!)
      updateManagerAppointmentsNumber()
    } else {
      context = appointmentToEdit.managedObjectContext
      let cost = Int32.parse(fromString: costField.text!)
      appointmentToEdit.thePatient?.totalFees += previousCost != 0 ? cost - previousCost : cost
    }
    appointmentToEdit.date = chosenDate
    appointmentToEdit.theOperator = operatorField.text
    appointmentToEdit.assistant = assistantField.text
    appointmentToEdit.procedure = procedureView.text 
    let dateformatter = DateFormatter()
    dateformatter.dateFormat = "dd.MM.yy"
    appointmentToEdit.comparisonDate = dateformatter.string(from: chosenDate!)
    appointmentToEdit.id = UUID().uuidString
    if !(costField.text?.isEmpty)! || costField.text == "0" {
      appointmentToEdit.cost = Int32.parse(fromString: costField.text!)
    } else {
      appointmentToEdit.cost = 0
      delegate?.didRemoveCost()
    }
    do {
      try context.save()
      if delegate != nil {
        delegate.didEditAppointment(appointmentToEdit)
      }
      navigationController?.popViewController(animated: true)
    } catch {
      print(error)
    }
  }
  
  private func updateManagerAppointmentsNumber() {
    if isSameMonth() {
      theManager?.income?.appointmentsNumber += 1
    } else {
      let context = AppDelegate.context
      if let manager = Manager.getManagerForDate(date: chosenDate!,context: context) {
        manager.income?.appointmentsNumber += 1
      } else {
        let manager = Manager(context: context)
        manager.newMonthManager(context: context)
        manager.month = chosenDate
        manager.income?.appointmentsNumber = 1
      }
    }
  }
  
  private func isSameMonth() -> Bool {
    let calendar = Calendar.current
    let presentDateComponents = calendar.dateComponents([.month], from: Date())
    let appointmentComponents = calendar.dateComponents([.month], from: chosenDate!)
    
    let sameMonth = presentDateComponents.month == appointmentComponents.month
    return sameMonth
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
