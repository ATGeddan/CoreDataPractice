//
//  PatientVC.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 12/2/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import CoreData

class PatientVC: UIViewController, UITextViewDelegate {
  
  @IBOutlet weak var chiefCompLbl: UILabel!
  @IBOutlet weak var chiefCompView: UITextView!
  var patient: Patient!
  @IBOutlet var dentitionButtons: [DentitionBtn]!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    chiefCompView.delegate = self
    recieveDentition()
    recievePatientData()
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.text == "Chief Complain ..." {
      textView.textColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
      textView.layer.borderColor = #colorLiteral(red: 0.004859850742, green: 0.09608627111, blue: 0.5749928951, alpha: 1)
      textView.text = ""
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.textColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
      textView.layer.borderColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
      textView.text = "Chief Complain ..."
    } else {
      patient.chiefComplain = textView.text!
      patient.complainDate = Date()
      do {
        try patient.managedObjectContext?.save()
        recievePatientData()
      } catch {
        
      }
    }
  }
  
  @IBAction func dentitionBtnPressed(_ sender: DentitionBtn) {
    view.endEditing(true)
    if sender.status < 8 {
      sender.status += 1
    } else {
      sender.status = 0
    }
    sender.updateButtonUI(sender.status)
    editOrCreateDentition(sender)
  }
  
  private func editOrCreateDentition(_ sender: DentitionBtn) {
    if patient.dentition == nil, let context = patient.managedObjectContext {
      let dentition = Dentition(context: context)
      dentition.thePatient = patient
      do {
        try context.save()
        editOrCreateDentition(sender)
      } catch {
        print(error)
      }
    } else {
      let dentition = patient.dentition!
      let tooth = sender.getToothName()
      dentition.setValue(sender.status, forKey: tooth)
      try? dentition.managedObjectContext?.save()
    }
  }
  
  private func recievePatientData() {
    guard let theComplain = patient.chiefComplain, let compDate = patient.complainDate else {return}
    chiefCompView.text = theComplain
    let theDateString = DateFormatter.localizedString(from: compDate, dateStyle: .medium, timeStyle: .none)
    chiefCompLbl.text = "Chief Complain at \(theDateString)"
    chiefCompView.layer.borderWidth = 1
    chiefCompView.layer.borderColor = #colorLiteral(red: 0.2605174184, green: 0.2605243921, blue: 0.260520637, alpha: 1)
    chiefCompView.layer.cornerRadius = 10
  }
  
  private func recieveDentition() {
    guard let dentition = patient.dentition else {
      for Btn in dentitionButtons {
        Btn.updateButtonUI(0)
      }
      return
    }
    for Btn in dentitionButtons {
      let tooth = Btn.getToothName()
      let theStatus = dentition.value(forKey: tooth) as! Int
      Btn.status = theStatus
      Btn.updateButtonUI(theStatus)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? AppointmentsTableViewController {
      destination.patient = patient
    }
    if let destination = segue.destination as? MedicalHistoryVC {
      destination.patient = patient
    }
  }
}

class DentitionBtn: UIButton {
  var status = 0
  
  func updateButtonUI(_ status: Int) {
    layer.cornerRadius = 15
    setTitleColor(.white, for: .normal)
    switch status {
    case 0:
      setTitleColor(.darkGray, for: .normal)
      layer.borderWidth = 1.5
      layer.borderColor = UIColor.darkGray.cgColor
      backgroundColor = .white
    case 1:
      setTitleColor(.black, for: .normal)
      layer.borderWidth = 0
      backgroundColor = .yellow
    case 2:
      setTitleColor(.white, for: .normal)
      backgroundColor = .blue
    case 3:
      setTitleColor(.black, for: .normal)
      backgroundColor = .gray
    case 4:
      setTitleColor(.white, for: .normal)
      backgroundColor = .black
    case 5:
      backgroundColor = .brown
    case 6:
      backgroundColor = .purple
    case 7:
      backgroundColor = .red
    case 8:
      backgroundColor = .orange
    default:
      break
    }
  }
  
  func getToothName() -> String {
    switch tag {
    case 1...8:
      return "ur\(tag)"
    case 9...16:
      return "ul\(tag - 8)"
    case -8...(-1):
      return "lr\(tag * -1)"
    case -16...(-9):
      return "ll\((tag + 8) * -1)"
    default:
      break
    }
    return "??"
  }
  
}
