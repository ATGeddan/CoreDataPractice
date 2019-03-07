//
//  AddPaymentVC.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 3/5/19.
//  Copyright © 2019 Ahmed Eltabbal. All rights reserved.
//

import UIKit

class AddPaymentVC: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {

  @IBOutlet weak var notesView: UITextView!
  @IBOutlet weak var categoryBtn: UIButton!
  @IBOutlet weak var categoryPicker: UIPickerView!
  @IBOutlet weak var paymentField: SkyFloatingLabelTextField!
  
  private let categories = ["Choose","Staff","Technician","Materials","Services","Others"]
  private var selectedCategory: String?
  var theManager: Manager?
  var addedNewPayment: ((Payment)->Void)?
  var chosenDate: Date?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    notesView.delegate = self
    categoryPicker.dataSource = self
    categoryPicker.delegate = self
    setupNotesView()
  }
  
  private func setupNotesView() {
    notesView.layer.cornerRadius = 5
    notesView.layer.borderWidth = 1
    notesView.layer.borderColor = #colorLiteral(red: 0.07090329379, green: 0.1490469873, blue: 0.1254850328, alpha: 1)
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.text == "Notes ..." {
      textView.text = ""
      textView.layer.borderColor = #colorLiteral(red: 0.95643121, green: 0.9217674732, blue: 0.8157092333, alpha: 1)
    }
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text == "" {
      textView.text = "Notes ..."
    }
    textView.layer.borderColor = #colorLiteral(red: 0.07090329379, green: 0.1490469873, blue: 0.1254850328, alpha: 1)
  }
  
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return categories.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return categories[row]
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if row == 0 {return}
    categoryPicker.isHidden = true
    notesView.alpha = 1
    categoryBtn.setTitle(categories[row], for: .normal)
    selectedCategory = categories[row]
  }

  @IBAction func categoryPressed(_ sender: UIButton) {
    categoryPicker.isHidden = !categoryPicker.isHidden
    notesView.alpha = categoryPicker.isHidden ? 1 : 0.2
  }
  
  @IBAction func dismissPressed(_ sender: UIButton) {
    dismiss(animated: true)
  }
  
  @IBAction func submitPressed(_ sender: UIButton) {
    view.endEditing(true)
    checkManager()
  }
  
  private func checkManager() {
    if theManager != nil {
      createNewPayment()
      return
    }
    let context = AppDelegate.context
    let newManager = Manager(context: context)
    newManager.newMonthManager(context: context)
    newManager.month = chosenDate
    do {
      try context.save()
      theManager = newManager
      createNewPayment()
    } catch {
      print(error)
    }
  }
  
  private func createNewPayment() {
    guard selectedCategory != nil, !(paymentField.text?.isEmpty)!, paymentField.text != "0" else {return}
    let context = theManager?.expense?.managedObjectContext ?? AppDelegate.context
    let payment = Payment(context: context)
    let amount = Int32.parse(fromString: paymentField.text!)
    payment.amount = amount
    payment.totalExpenses = theManager?.expense
    theManager?.expense?.total += amount
    payment.category = selectedCategory
    payment.date = Date()
    payment.id = theManager?.id
    if notesView.text != "Notes ..." {
      payment.notes = notesView.text
    }
    do {
      try context.save()
      addedNewPayment?(payment)
      dismiss(animated: true)
    } catch {
      print(error)
    }
  }
  
}
