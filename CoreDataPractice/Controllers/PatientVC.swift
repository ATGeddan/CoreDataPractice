//
//  PatientVC.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 12/2/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import CoreData
import Photos

class PatientVC: UIViewController {
  
  @IBOutlet weak var imageFrame: UIImageView!
  @IBOutlet weak var nextVisitLabel: UILabel!
  @IBOutlet weak var lastVisitLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var phoneLabel: UILabel!
  @IBOutlet weak var genderLabel: UILabel!
  @IBOutlet weak var birthLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var patientPhoto: SLImageView!
  @IBOutlet fileprivate weak var infoArrow: UIButton!
  @IBOutlet fileprivate weak var dentitionArrow: UIButton!
  @IBOutlet fileprivate weak var dentitionConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var infoTopConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var vipSwitch: UISwitch!

  @IBOutlet fileprivate var dentitionButtons: [DentitionBtn]!
  @IBOutlet fileprivate var actionButtons: [UIButton]!
  
  lazy fileprivate var imagePicker = UIImagePickerController()
  var patient: Patient!
  fileprivate var editingVIPstate: Int16?
  fileprivate var uiStatus: uiOptions = .neither {
    didSet {
      switch uiStatus {
      case .dentition:
        dentitionArrow.rotate90()
        infoArrow.rotate0()
      case .info:
        infoArrow.rotate90()
        dentitionArrow.rotate0()
      case .neither:
        infoArrow.rotate0()
        dentitionArrow.rotate0()
      }
    }
  }
  
  fileprivate enum uiOptions {
    case dentition
    case info
    case neither
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupButtonsLayer()
    recieveDentition()
    recieveVIPstate()
    recievePatientInfo()
    setupPhotoDeletion()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    checkVIPchange()
  }
  
  @IBAction func vipSwitched(_ sender: UISwitch) {
    switch sender.isOn {
    case true :
      editingVIPstate = 3
    case false:
      if patient.status != 3 {
        editingVIPstate = patient.status
      } else if patient.isStillNew {
        editingVIPstate = 1
      } else {
        editingVIPstate = 0
      }
    }
  }
  
  private func recievePatientInfo() {
    if let photoData = patient.imageData {
      patientPhoto.image = UIImage(data: photoData)
    } else {
      patientPhoto.image = UIImage(named: "\(patient.gender!)placeholder")
    }
    nameLabel.text = patient.name
    birthLabel.text = formatDate(patient.birth!)
    phoneLabel.text = patient.phone
    addressLabel.text = patient.address
    genderLabel.text = patient.gender
    lastVisitLabel.text = patient.lastVisitDate != nil ? formatDate(patient.lastVisitDate!) : "--/--/----"
    nextVisitLabel.text = patient.nextVisitDate != nil ? formatDate(patient.nextVisitDate!) : "--/--/----"
  }
  
  private func setupPhotoDeletion() {
    guard patient.imageData != nil else {return}
    let longpress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
    let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    imageFrame.isUserInteractionEnabled = true
    imageFrame.addGestureRecognizer(longpress)
    imageFrame.addGestureRecognizer(tap)
  }
  
  @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
    let alert = UIAlertController(title: "Delete This Photo?", message: "", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {[weak self] _ in
      self?.patient.imageData = nil
      try? self?.patient.managedObjectContext?.save()
      self?.patientPhoto.image = UIImage(named: "\((self?.patient.gender)!)placeholder")
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(alert,animated: true)
  }
  
  @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
    guard patient.imageData != nil else {return}
    patientPhoto.showFullscreen()
  }
  
  private func formatDate(_ date: Date) -> String {
    let dateString = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
    return dateString
  }
  
  private func setupButtonsLayer() {
    for button in actionButtons {
      button.layer.cornerRadius = 5
    }
    patientPhoto.layer.cornerRadius = 24
  }
  
  private func checkVIPchange() {
    if editingVIPstate != nil && editingVIPstate != patient.status {
      patient.status = editingVIPstate!
      guard let context = patient.managedObjectContext else {return}
      do {
        try context.save()
      } catch {
        print(error)
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
  
  private func recieveVIPstate() {
    if patient.status == 3 {
      vipSwitch.isOn = true
    }
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

// MARK: Animations

extension PatientVC {
  
  @IBAction func dentitionPressed(_ sender: UIButton!) {
    let old = uiStatus
    uiStatus = old == .dentition ? .neither : .dentition
    toggleViews(oldStatus: old)
  }
  
  @IBAction func infoPressed(_ sender: UIButton!) {
    let old = uiStatus
    uiStatus = old == .info ? .neither : .info
    toggleViews(oldStatus: old)
  }
  
  // info 0 show -300 hide
  // dentition 0 show 250 hide
  
  private func toggleViews(oldStatus: uiOptions) {
    let newStatus = uiStatus
    switch newStatus {
    case .dentition where oldStatus == .neither, .neither where oldStatus == .dentition:
      toggleDentition {}
    case .info where oldStatus == .neither, .neither where oldStatus == .info:
      toggleInfo {}
    case .info where oldStatus == .dentition, .dentition where oldStatus == .info:
      switchViews()
    default:
      break
    }
  }
  
  private func switchViews() {
    
    if infoTopConstraint.constant == 0 { // Info view is showing
      toggleInfo {[weak self] in
        self?.toggleDentition {}
      }
    } else { // dentition is showing
      toggleDentition {[weak self] in
        self?.toggleInfo {}
      }
    }
  }
  
  private func toggleDentition(completion: @escaping ()->Void) {
    UIView.animate(withDuration: 0.3, animations: {[weak self] in
      self?.dentitionConstraint.constant = self?.dentitionConstraint.constant == 250 ? 0 : 250
      self?.view.layoutIfNeeded()
    }, completion: { _ in
      completion()
    })
  }
  
  private func toggleInfo(completion: @escaping ()->Void) {
    UIView.animate(withDuration: 0.3, animations: {[weak self] in
      self?.infoTopConstraint.constant = self?.infoTopConstraint.constant == 0 ? -300 : 0
      self?.view.layoutIfNeeded()
    }, completion: { _ in
      completion()
    })
  }
  
}

// MARK: Image Picker

extension PatientVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  @IBAction private func changePhoto(_ sender: UIButton!) {
    imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    imagePicker.allowsEditing = true
    let status = PHPhotoLibrary.authorizationStatus()
    switch status {
    case .authorized:
      self.present(self.imagePicker,animated: true,completion: nil)
    case .denied, .restricted :
      self.handleAccessDeny()
    case .notDetermined:
      PHPhotoLibrary.requestAuthorization() { status in
        switch status {
        case .authorized:
          self.present(self.imagePicker,animated: true,completion: nil)
        case .denied, .restricted:
          self.handleAccessDeny()
        case .notDetermined:
          break
        }
      }
    }
  }
  
  fileprivate func handleAccessDeny() {
    let alert = UIAlertController(title: "Access denied", message: "You need to allow access to your gallery to upload an image.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Go to settings", style: .default, handler: { _ in
      let settingsUrl = NSURL(string:UIApplication.openSettingsURLString)
      if let url = settingsUrl {
        DispatchQueue.main.async {
          UIApplication.shared.open(url as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil) //(url as URL)
        }
      }
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    self.present(alert,animated: true,completion: nil)
  }
  
  internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    // Local variable inserted by Swift 4.2 migrator.
    let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
    
    if let chosenImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
      guard let imageData = chosenImage.jpegData(compressionQuality: 1) else {return}
      patientPhoto.image = chosenImage
      patient.imageData = imageData
      do {
        try patient.managedObjectContext?.save()
      } catch {
        presentBasicAlert(title: "Error", message: "Try setting the patient's photo again.")
      }
      imagePicker.dismiss(animated: true, completion: nil)
    }
  }
  

  
}

// Helper function inserted by Swift 4.2 migrator.
func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
  return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
  return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
  return input.rawValue
}
