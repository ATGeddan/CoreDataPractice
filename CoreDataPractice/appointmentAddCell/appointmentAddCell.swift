//
//  appointmentAddCell.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 11/14/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import CoreData

class appointmentAddCell: UITableViewCell {

  @IBOutlet weak var dateField: UITextField!
  @IBOutlet weak var operatorField: UITextField!
  @IBOutlet weak var assistantField: UITextField!
  
  var patient: Patient?
  
  override func awakeFromNib() {
        super.awakeFromNib()
    
    }

  @IBAction func addClicked(_ sender: UIButton) {
    guard let context = patient?.managedObjectContext else {return}
    let appoint = Appointment(context: context)
    appoint.date = dateField.text!
    appoint.theOperator = operatorField.text!
    appoint.assistant = assistantField.text!
    appoint.thePatient = patient
    try? context.save()
    dateField.text = ""
    operatorField.text = ""
    assistantField.text = ""
    print("Saved Appointment")
  }
  
}
