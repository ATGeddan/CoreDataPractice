//
//  AppointmentVC.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 11/18/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import CoreData
import Photos

protocol DidEditAppointmentDelegate {
  func didEditAppointment(_ appoint: Appointment)
  func didRemoveCost()
}

class AppointmentVC: UIViewController, UITextFieldDelegate ,UIImagePickerControllerDelegate, UINavigationControllerDelegate, DidEditAppointmentDelegate {
  
  @IBOutlet weak var costLabel: UILabel!
  @IBOutlet weak var costField: SkyFloatingLabelTextField!
  @IBOutlet weak var addPhotoBtn2: UIButton!
  @IBOutlet weak var addPhotoBtn: UIButton!
  @IBOutlet weak var picsScrollView: UIScrollView!
  @IBOutlet weak var procedureView: UITextView!
  @IBOutlet weak var assistantLabel: UILabel!
  @IBOutlet weak var operatorLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var scrollWidth: NSLayoutConstraint!
  
  
  var appointment: Appointment?
  var allImgs = [Picture]()
  lazy var imagePicker = UIImagePickerController()
  private let container = AppDelegate.persistentContainer
  
  override func viewDidLoad() {
    super.viewDidLoad()
    costField.delegate = self
    costLabel.isHidden = true
    setupEditButton()
    setupAppointmentData()
    fetchAppointmentPictures()
  }
  
  func didEditAppointment(_ appoint: Appointment) {
    appointment = appoint
    setupAppointmentData()
  }
  
  func didRemoveCost() {
    setupCost()
  }
  
  private func setupCost() {
    if let cost = appointment?.cost, cost != 0 {
      costField.isHidden = true
      costLabel.text = "\(cost)L.E."
      costLabel.isHidden = false
    } else {
      costField.isHidden = false
      costLabel.isHidden = true
      costField.text = ""
      costLabel.text = ""
    }
  }
  
  private func setupAppointmentData() {
    guard let theOperator = appointment?.theOperator,
          let procedure = appointment?.procedure,
          let theDate = appointment?.date,
          let name = appointment?.thePatient?.name else {return}
    let dateString = DateFormatter.localizedString(from: theDate, dateStyle: .medium, timeStyle: .short)
    dateLabel.text = dateString
    operatorLabel.text = "Operator: \(theOperator)"
    procedureView.text = "Procedure : \(procedure)"
    setupCost()
    navigationItem.title = name
    
    if let assistant = appointment?.assistant, assistant != "" {
      assistantLabel.isHidden = false
      assistantLabel.text = "Assistant: \(assistant)"
    } else {
      assistantLabel.isHidden = true
    }
  }
  
  private func setupEditButton() {
    let rightButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(goToEdit))
    navigationItem.rightBarButtonItem = rightButton
    // Hide secondery add button
    addPhotoBtn2.alpha = 0
  }
  
  @objc private func goToEdit() {
    performSegue(withIdentifier: "toEditAppoint", sender: appointment)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    let cost = Int32.parse(fromString: textField.text!)
    appointment?.cost = cost
    do {
      try appointment?.managedObjectContext?.save()
      textField.isHidden = true
      costLabel.text = "\(cost)L.E."
      costLabel.isHidden = false
      if let patient = appointment?.thePatient {
        patient.totalFees += cost
      }
    } catch {
      print(error.localizedDescription)
    }    
  }
  
  private func fetchAppointmentPictures() {
    allImgs = []
    let request: NSFetchRequest<Picture> = Picture.fetchRequest()
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
    request.sortDescriptors = [sortDescriptor]
    request.predicate = NSPredicate(format: "theAppointment = %@", appointment!)
    container.performBackgroundTask { [weak self] context in
      do {
        let allImgs = try context.fetch(request)
        self?.allImgs = allImgs
        self?.handleFetchedPictures((self?.allImgs)!)
      } catch {
        print(error)
      }
    }
  }
  
  private func handleFetchedPictures(_ array: [Picture]) {
    if array.count > 0 {
      DispatchQueue.main.async { [weak self] in
        self?.addPicsToScrollView(array)
      }
    }
  }
  
  func relayPictures(_ thisImg: SLImageView) {
    picsScrollView.addSubview(thisImg)
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
      self.view.layoutIfNeeded()
      thisImg.alpha = 1
      for pic in self.picsScrollView.subviews {
        if let thisPic = pic as? SLImageView, thisPic.imageID >= 0 {
          thisPic.imageID += 1
          thisPic.center.x += 260
        }
      }
    }) { [weak self]_ in
      thisImg.imageID = 0
      self?.scrollWidth.constant = CGFloat((((self?.picsScrollView.subviews.count)! - 2) * 260) + 15)
    }
    addPhotoBtn.alpha = 0
    addPhotoBtn2.alpha = 1
  }
  
  private func addPicsToScrollView(_ array: [Picture]) {
    addPhotoBtn.alpha = 0
    addPhotoBtn2.alpha = 1
    for i in 0..<array.count {
      let currentImage = array[i]
      let theNewImage = setupNewImage(index: i, withImage: currentImage)
      picsScrollView.addSubview(theNewImage)
      UIView.animate(withDuration: 0.2) {
        theNewImage.alpha = 1
      }
    }
    scrollWidth.constant = CGFloat((array.count * 260) + 15)
  }
  
  @objc private func saveDeleteAlert(_ sender: UILongPressGestureRecognizer) {
    
    let actionSheet = UIAlertController(title: "Save or Delete", message: "Do you want to save or delete this image?", preferredStyle: .actionSheet)
    actionSheet.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self]_ in
      if let thisImage = sender.view as? SLImageView {
        self?.saveTriggered(thisImage.image!)
      }
    }))
    actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self]_ in
      self?.deleteTriggered(sender)
    }))
    actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(actionSheet,animated: true)
  }
  
  private func saveTriggered(_ img:UIImage) {
    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
  }
  
  private func deleteTriggered(_ sender: UILongPressGestureRecognizer) {
    
    if let thisImg = sender.view as? SLImageView {
      let theObject = allImgs[thisImg.imageID]
      guard let context = theObject.managedObjectContext else {return}
      context.delete(theObject)
      try? context.save()
      
      imageCache.removeObject(forKey: theObject.id as AnyObject)
      UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
        self.view.layoutIfNeeded()
        thisImg.alpha = 0
        for pic in self.picsScrollView.subviews {
          if let thisPic = pic as? SLImageView, thisPic.imageID > thisImg.imageID {
            thisPic.imageID -= 1
            thisPic.center.x -= 260
          }
        }
      }) { [weak self]_ in
        thisImg.removeFromSuperview()
        self?.allImgs.remove(at: thisImg.imageID)
        self?.scrollWidth.constant = CGFloat((((self?.picsScrollView.subviews.count)! - 2) * 260) + 15)
        if self?.picsScrollView.subviews.count == 2 {
          UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
            self?.addPhotoBtn.alpha = 1
            self?.addPhotoBtn2.alpha = 0
          })
        }
      }
    }
  }
  
  @IBAction func addPhotoClicked(_ sender: UIButton) {
    askForPermission()
  }
  
  private func askForPermission() {  // Check permission
    imagePicker = UIImagePickerController()
    imagePicker.delegate = self
    let status = PHPhotoLibrary.authorizationStatus()
    switch status {
    case .authorized:
      self.present(self.imagePicker,animated: true,completion: nil)
      break
    case .denied, .restricted :
      self.handleAccessDeny()
      break
    case .notDetermined:
      PHPhotoLibrary.requestAuthorization() { status in
        switch status {
        case .authorized:
          self.present(self.imagePicker,animated: true,completion: nil)
          break
        case .denied, .restricted:
          self.handleAccessDeny()
          break
        case .notDetermined:
          break
        }
      }
    }
  }
  
  private func handleAccessDeny() {
    let alert = UIAlertController(title: "Access denied", message: "You need to allow (APP NAME) access to your gallery to upload an image.", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Go to settings", style: .default, handler: { _ in
      let settingsUrl = NSURL(string:UIApplication.openSettingsURLString)
      if let url = settingsUrl {
        DispatchQueue.main.async {
          UIApplication.shared.open(url as URL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil) //(url as URL)
        }
      }
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(alert,animated: true,completion: nil)
  }
  
  @objc internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    // Local variable inserted by Swift 4.2 migrator.
    let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
    
    if let chosenImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
      guard let imageData = chosenImage.jpegData(compressionQuality: 1) else {return}
      guard let context = appointment?.managedObjectContext else {return}
      context.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
      let pic = Picture(context: context)
      pic.createNewPicture(data: imageData,appointment: appointment!)
      allImgs.insert(pic, at: 0)
      let theNewImage = setupNewImage(index:0, withImage: pic)
      theNewImage.imageID = -1
      imagePicker.dismiss(animated: true) {[weak self] in
        try? context.save()
        self?.relayPictures(theNewImage)
      }
    }
    
  }
  
  private func setupNewImage(index i: Int,withImage: Picture) -> SLImageView {
    let newX =  260 * CGFloat(i)
    let scrollheight = picsScrollView.frame.size.height
    let imageview = SLImageView(frame: CGRect(x:10 + newX , y:0 ,width:250, height:scrollheight))
    imageview.imageID = i
    imageview.image = UIImage(data: withImage.picData!)
    imageview.imageUsingCacheFromDatabase(key: withImage.id!)
    imageview.contentMode = .scaleToFill
    imageview.layer.borderWidth = 0.5
    imageview.layer.borderColor = UIColor(red: 140/255, green: 153/255, blue: 173/255, alpha: 0.5).cgColor
    imageview.layer.cornerRadius = 10
    imageview.clipsToBounds = true
    imageview.alpha = 0
    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(saveDeleteAlert))
    imageview.addGestureRecognizer(longPress)
    return imageview
  }
 
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let dest = segue.destination as? AddOrEditAppointmentVC, let appoint = sender as? Appointment {
      dest.delegate = self
      dest.appointmentToEdit = appoint
    }
  }
  
}






