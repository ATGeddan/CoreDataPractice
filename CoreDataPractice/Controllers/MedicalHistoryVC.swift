//
//  MedicalHistoryVC.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 12/2/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit

class MedicalHistoryVC: UIViewController, UITextFieldDelegate {

  @IBOutlet weak var femaleView: UIView!
  @IBOutlet weak var surgeryField: SkyFloatingLabelTextField!
  @IBOutlet weak var liverField: SkyFloatingLabelTextField!
  @IBOutlet weak var allergyField: SkyFloatingLabelTextField!
  @IBOutlet weak var showLiver: NSLayoutConstraint!
  @IBOutlet weak var showSurgery: NSLayoutConstraint!
  @IBOutlet weak var showAllergy: NSLayoutConstraint!
  @IBOutlet var freeButtons: [UIButton]!
  @IBOutlet var notButtons: [UIButton]!
  
  var patient: Patient!
  var startedEditing = false {
    didSet {
      let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveHistory))
      navigationItem.rightBarButtonItem = saveButton
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    surgeryField.delegate = self
    allergyField.delegate = self
    liverField.delegate = self
    setupUI()
  }

  @objc private func saveHistory() {
    view.endEditing(true)
    do {
      try patient.history?.managedObjectContext?.save()
      navigationController?.popViewController(animated: true)
    } catch {
      print(error)
    }
  }
  
  private func recieveHistory() {
    if let theHistory = patient.history {
      if theHistory.allergy != nil {
        updateButtonUI(tag: 0, isFree: false)
        allergyField.text = theHistory.allergy
      } else {
        updateButtonUI(tag: 0, isFree: true)
      }
      if theHistory.surgery != nil {
        updateButtonUI(tag: 1, isFree: false)
        surgeryField.text = theHistory.surgery
      } else {
        updateButtonUI(tag: 1, isFree: true)
      }
      if theHistory.liver != nil {
        updateButtonUI(tag: 2, isFree: false)
        liverField.text = theHistory.liver
      } else {
        updateButtonUI(tag: 2, isFree: true)
      }
      updateButtonUI(tag: 3, isFree: !theHistory.pressure)
      updateButtonUI(tag: 4, isFree: !theHistory.diabetes)
      updateButtonUI(tag: 5, isFree: !theHistory.renal)
      if patient.gender! == "Female" {
        updateButtonUI(tag: 6, isFree: !theHistory.pregnant)
        updateButtonUI(tag: 7, isFree: !theHistory.lactation)
      }
    }
  }
  
  private func setupUI() {
    showAllergy.constant = -50
    showSurgery.constant = -50
    showLiver.constant = -50
    allergyField.alpha = 0
    surgeryField.alpha = 0
    liverField.alpha = 0
    if patient.gender! == "Male" {
      femaleView.alpha = 0
    }
    recieveHistory()
  }

  @IBAction func freePressed(_ sender: UIButton) {
    updateButtonUI(tag: sender.tag, isFree: true)
    createOrUpdateHistory(tag: sender.tag, isFree: true)
  }
  
  @IBAction func notPressed(_ sender: UIButton) {
    updateButtonUI(tag: sender.tag, isFree: false)
    createOrUpdateHistory(tag: sender.tag, isFree: false)
  }
  
  private func createOrUpdateHistory(tag: Int, isFree: Bool) {
    if !startedEditing {
      startedEditing = true
    }
    if patient.history == nil, let context = patient.managedObjectContext {
      let history = MedicalHistory(context: context)
      history.thePatinet = patient
      do {
        try context.save()
        createOrUpdateHistory(tag: tag, isFree: isFree)
      } catch {
        print(error)
      }
    } else {
      let theHistory = patient.history!
      if isFree {
        switch tag {
        case 0:
          theHistory.allergy = nil
        case 1:
          theHistory.surgery = nil
        case 2:
          theHistory.liver = nil
        case 3:
          theHistory.pressure = false
        case 4:
          theHistory.diabetes = false
        case 5:
          theHistory.renal = false
        case 6:
          theHistory.pregnant = false
        case 7:
          theHistory.lactation = false
        default:
          break
        }
      } else {
        switch tag {
        case 0:
          theHistory.allergy = ""
        case 1:
          theHistory.surgery = ""
        case 2:
          theHistory.liver = ""
        case 3:
          theHistory.pressure = true
        case 4:
          theHistory.diabetes = true
        case 5:
          theHistory.renal = true
        case 6:
          theHistory.pregnant = true
        case 7:
          theHistory.lactation = true
        default:
          break
        }
      }
    }
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    startedEditing = true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    let theHistory = patient.history!
    switch textField.tag {
    case 0:
      theHistory.allergy = textField.text!
    case 1:
      theHistory.surgery = textField.text!
    case 2:
      theHistory.liver = textField.text!
    default:
      break
    }
  }
  
  private func updateButtonUI(tag: Int, isFree: Bool) {
    view.endEditing(true)
    guard let selectedFree = freeButtons.filter({$0.tag == tag}).first else {return}
    guard let selectedNot = notButtons.filter({$0.tag == tag}).first else {return}
    if isFree {
      selectedFree.isEnabled = false
      selectedNot.isEnabled = true
      selectedFree.setImage(UIImage(named: "FreeOn"), for: .normal)
      selectedNot.setImage(UIImage(named: "NotOff"), for: .normal)
      UIView.animate(withDuration: 0.1, animations: {[weak self] in
        switch tag {
        case 0:
          self?.allergyField.alpha = 0
        case 1:
          self?.surgeryField.alpha = 0
        case 2:
          self?.liverField.alpha = 0
        default:
          break
        }
        self?.view.layoutIfNeeded()
      }) {completed in
        if completed {
          UIView.animate(withDuration: 0.2, animations: {[weak self] in
            switch tag {
            case 0:
              self?.showAllergy.constant = -50
            case 1:
              self?.showSurgery.constant = -50
            case 2:
              self?.showLiver.constant = -50
            default:
              break
            }
            self?.view.layoutIfNeeded()
          })
        }
      }
    } else {
      selectedFree.isEnabled = true
      selectedNot.isEnabled = false
      selectedFree.setImage(UIImage(named: "FreeOff"), for: .normal)
      selectedNot.setImage(UIImage(named: "NotOn"), for: .normal)
      UIView.animate(withDuration: 0.2, animations: {[weak self] in
        switch tag {
        case 0:
          self?.showAllergy.constant = -10
        case 1:
          self?.showSurgery.constant = -10
        case 2:
          self?.showLiver.constant = -10
        default:
          break
        }
        self?.view.layoutIfNeeded()
      }) {completed in
        if completed {
          UIView.animate(withDuration: 0.1, animations: {[weak self] in
            switch tag {
            case 0:
              self?.allergyField.alpha = 1
            case 1:
              self?.surgeryField.alpha = 1
            case 2:
              self?.liverField.alpha = 1
            default:
              break
            }
            self?.view.layoutIfNeeded()
          })
        }
      }
    }
  }
  
}
