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

class PatientVC: UIViewController, UITextFieldDelegate , EditingPatientDelegate {
  
  @IBOutlet weak var addPaymentBtn: UIButton!
  @IBOutlet weak var feesField: SkyFloatingLabelTextField!
  @IBOutlet weak var statusBtn: UIButton!
  @IBOutlet weak var imageFrame: UIImageView!
  @IBOutlet weak var nextVisitLabel: UILabel!
  @IBOutlet weak var lastVisitLabel: UILabel!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var phoneLabel: UILabel!
  @IBOutlet weak var feesLabel: UILabel!
  @IBOutlet weak var birthLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var patientPhoto: SLImageView!
  @IBOutlet fileprivate weak var infoArrow: UIButton!
  @IBOutlet fileprivate weak var dentitionArrow: UIButton!
  @IBOutlet fileprivate weak var dentitionConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var infoTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var guideHeight: NSLayoutConstraint!
  
  @IBOutlet fileprivate var dentitionButtons: [DentitionBtn]!
  @IBOutlet fileprivate var actionButtons: [UIButton]!
  @IBOutlet weak var decidiousStack: UIStackView!
  @IBOutlet fileprivate var permenantStacks: [UIStackView]!
  
  lazy fileprivate var imagePicker = UIImagePickerController()
  var patient: Patient!
  fileprivate var uiStatus: uiOptions = .neither
  fileprivate let container = AppDelegate.persistentContainer
  fileprivate var theManager: Manager?

  fileprivate var dentitionType: dentTypes?
  fileprivate enum dentTypes {
    case decidious
    case permenant
    case mixed
  }
  
  fileprivate enum uiOptions {
    case dentition
    case info
    case neither
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    feesField.delegate = self
    setupButtonsLayerAndEditButton()
    recieveDentition()
    recieveState()
    setupPhotoDeletion()
    getTheManager()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    recievePatientInfo(patient)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    checkStateChange()
  }
  
  private func recievePatientInfo(_ patient: Patient) {
    if let photoData = patient.imageData {
      patientPhoto.image = UIImage(data: photoData)
    } else {
      patientPhoto.image = UIImage(named: "\(patient.gender!)placeholder")
    }
    nameLabel.text = patient.name
    birthLabel.text = formatDate(patient.birth!)
    phoneLabel.text = patient.phone
    addressLabel.text = patient.address
    feesLabel.text = "\(patient.totalFees) L.E."
    addPaymentBtn.isHidden = !(patient.totalFees > 0)
    lastVisitLabel.text = patient.lastVisitDate != nil ? formatDate(patient.lastVisitDate!) : "--/--/----"
    nextVisitLabel.text = patient.nextVisitDate != nil ? formatDate(patient.nextVisitDate!) : "--/--/----"
    switch calculateAge(birthDate: patient.birth!) {
    case 0...6:
      dentitionType = .decidious
    case 7...13:
      dentitionType = .mixed
    case 14...:
      dentitionType = .permenant
    default:
      break
    }
    setupProperDentition()
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
  
  private func setupButtonsLayerAndEditButton() {
    for button in actionButtons {
      button.layer.cornerRadius = 5
    }
    patientPhoto.layer.cornerRadius = 24
    let edit = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(goToEdit))
    navigationItem.rightBarButtonItem = edit
  }
  
  @objc private func goToEdit() {
    performSegue(withIdentifier: "editPatient", sender: patient)
  }
  
  private func checkStateChange() {
    guard let context = patient.managedObjectContext else {return}
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        print(error)
      }
    }
  }
  
  @IBAction func dentitionBtnPressed(_ sender: DentitionBtn) {
    view.endEditing(true)
    if sender.type == .permenant {
      sender.status < 8 ? (sender.status += 1) : (sender.status = 0)
    } else if sender.type == .decidious {
      sender.status < 7 ? (sender.status += 1) : (sender.status = 0)
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
  
  private func recieveState() {
    switch patient.status {
    case 1:
      statusBtn.setImage(patient.isStillNew ? #imageLiteral(resourceName: "New") : #imageLiteral(resourceName: "Logo"), for: .normal)
    case 2:
      statusBtn.setImage(#imageLiteral(resourceName: "High risk"), for: .normal)
    case 3:
      statusBtn.setImage(#imageLiteral(resourceName: "VIP"), for: .normal)
    default:
      break
    }
  }
  
  @IBAction func statusButtonPressed(_ sender: UIButton) {
    patient.status < 3 ? (patient.status += 1) : (patient.status = 1)
    recieveState()
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
  
  private func getTheManager() {
    let context = container.viewContext
    if let manager = Manager.getManagerForDate(date: Date(), context: context) {
      theManager = manager
    }
  }
  
  @IBAction func payFees(_ sender: UIButton) {
    feesField.isHidden = false
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField.text != "0" && !(textField.text?.isEmpty)! {
      presentConfirmationAlert()
    } else {
      textField.isHidden = true
      textField.text = ""
    }
  }
  
  private func presentConfirmationAlert() {
    let alert = UIAlertController(title: "Confirm \(feesField.text!) L.E ?", message: "Do you want to confirm this payment?", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {[weak self] _ in
      self?.confirmPayment()
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {[weak self] _ in
      self?.feesField.isHidden = true
      self?.feesField.text = ""
    }))
    present(alert, animated: true)
  }
  
  private func confirmPayment() {
    guard let amount = feesField.text else {return}
    let amountInt = Int32.parse(fromString: amount)
    let newFees = patient.totalFees - amountInt
    feesLabel.text = "\(newFees) L.E."
    patient.totalFees -= amountInt
    patient.paidAmount += amountInt
    createPaymentAmount(theAmount: amountInt)
    addPaymentBtn.isHidden = (amountInt == 0)
    do {
      try patient.managedObjectContext?.save()
      feesField.isHidden = true
      feesField.text = ""
    } catch {
      print(error)
    }
  }
  
  private func createPaymentAmount(theAmount: Int32) {
    guard let context = patient.managedObjectContext else { return }
    let payment = IncomeAmount(context: context)
    payment.amount = theAmount
    payment.thePatient = patient
    payment.patientName = patient.name
    payment.id = theManager?.id
    payment.date = Date()
    payment.totalIncome = theManager?.income
    theManager?.income?.total += theAmount
  }
  
  func didEditPatient(_ patient: Patient) {
    recievePatientInfo(patient)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? AppointmentsTableVC {
      destination.patient = patient
    }
    if let destination = segue.destination as? MedicalHistoryVC {
      destination.patient = patient
    }
    if let dest = segue.destination as? AddPatientVC, let patient = sender as? Patient {
      dest.patientToEdit = patient
      dest.delegate = self
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
  
  func setupProperDentition() {
    for stack in permenantStacks {
      stack.layer.zPosition = 1
    }
    
    switch dentitionType {
    case .decidious?:
      guideHeight.constant = 160
      for stack in permenantStacks {
        stack.isHidden = true
        stack.isUserInteractionEnabled = false
      }
      decidiousStack.layer.zPosition = 2
    case .permenant?:
      guideHeight.constant = 160
      decidiousStack.isHidden = true
      decidiousStack.isUserInteractionEnabled = false
    case .mixed?:
      guideHeight.constant = 90
    default:
      break
    }
  }
  
  // info 0 show -326 hide
  // dentition 280 show 0 hide
  // guide height 90 mixed 160 Not
  
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
    let constraint = dentitionConstraint.constant
    UIView.animate(withDuration: 0.3, animations: {
      self.dentitionConstraint.constant = constraint == 0 ? 280 : 0
      self.dentitionArrow.transform = CGAffineTransform(rotationAngle: constraint == 0 ? 90 * (.pi / 180) : 0)
      self.view.layoutIfNeeded()
    }, completion: { _ in
      completion()
    })
  }
  
  private func toggleInfo(completion: @escaping ()->Void) {
    let constraint = infoTopConstraint.constant
    UIView.animate(withDuration: 0.3, animations: {
      self.infoTopConstraint.constant = constraint == -326 ? 0 : -326
      self.infoArrow.transform = CGAffineTransform(rotationAngle: constraint == -326 ? 90 * (.pi / 180) : 0)
      self.view.layoutIfNeeded()
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
      patient.imageData = imageData
      do {
        try patient.managedObjectContext?.save()
        patientPhoto.image = chosenImage
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
