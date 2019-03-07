//
//  IncomeVC.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 3/3/19.
//  Copyright © 2019 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import CoreData

class IncomeVC: UIViewController, UITextFieldDelegate {

  @IBOutlet weak var changeFeeBtn: UIButton!
  @IBOutlet weak var entryFeeLabel: UILabel!
  @IBOutlet weak var paymentsTableView: UITableView!
  @IBOutlet weak var fixedPaymentField: SkyFloatingLabelTextField!
  @IBOutlet weak var totalIncomeLabel: UILabel!
  @IBOutlet weak var appointmentsNumberLabel: UILabel!
  @IBOutlet weak var patientsNumberLabel: UILabel!
  
  private let container = AppDelegate.persistentContainer
  private var chosenDate = Date()
  private var theManager: Manager? {
    didSet {  fetchPayments() }
  }
  private var payments = [IncomeAmount]() {
    didSet { paymentsTableView.reloadData() }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    fixedPaymentField.delegate = self
    paymentsTableView.register(UINib(nibName: "IncomeCell", bundle: nil), forCellReuseIdentifier: IncomeCell.identifier)
    fetchManagerAndPayments(forDate: chosenDate)
    tabBarController?.tabBar.tintColor = #colorLiteral(red: 0.95643121, green: 0.9217674732, blue: 0.8157092333, alpha: 1)
    tabBarController?.tabBar.unselectedItemTintColor = #colorLiteral(red: 0.07090329379, green: 0.1490469873, blue: 0.1254850328, alpha: 1)
  }
  
  private func fetchManagerAndPayments(forDate date: Date) {
    let context = container.viewContext
    if let manager = Manager.getManagerForDate(date: date, context: context) {
      fixEntryFee(newManager: manager)
      theManager = manager
      fetchPayments()
    } else {
      payments = []
      theManager = nil
      changeFeeBtn.isHidden = true
    }
  }
  
  private func fixEntryFee(newManager: Manager) {
    if let newEntryFee = newManager.income?.fixedFee, let trueEntryFee = theManager?.income?.fixedFee {
      if newEntryFee != trueEntryFee {
        newManager.income?.fixedFee = trueEntryFee
        do {
          try newManager.managedObjectContext?.save()
        } catch {
          print(error)
        }
      }
    }
  }
  
  private func getAnotherManager(next: Bool) {
    let calendar = Calendar.current
    let chosenDateComponents = calendar.dateComponents([.year,.month], from: chosenDate)
    
    let selectedMonth = chosenDateComponents.month
    let selectedYear = chosenDateComponents.year
    var components = DateComponents()
    components.month = selectedMonth
    components.year = selectedYear
    guard let dateOfChosenMonth = Calendar.current.date(from: components) else {return}
    components.year = 0
    components.day = 0
    if next {
      components.month = 1
      guard let dateOfNextMonth = Calendar.current.date(byAdding: components, to: dateOfChosenMonth) else {return}
      chosenDate = dateOfNextMonth
    } else {
      components.month = -1
      guard let dateOfLastMonth = Calendar.current.date(byAdding: components, to: dateOfChosenMonth) else {return}
      chosenDate = dateOfLastMonth
    }
    fetchManagerAndPayments(forDate: chosenDate)
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    navigationItem.title = formatter.string(from: chosenDate)
  }
  
  private func displayData() {
    var appNum: Int32 = 0
    var patNum: Int32 = 0
    
    if let income = theManager?.income {
      appNum = income.appointmentsNumber
      patNum = income.patientsNumber
    }
    appointmentsNumberLabel.text = String(appNum) + "\n" + (appNum != 1 ? " Appointments" : " Appointment")
    patientsNumberLabel.text = String(patNum) + "\n" + (patNum != 1 ? " Patients" : " Patient")
    setupTotalIncome()
    setupEntryFee()
  }
  
  private func setupTotalIncome() {
    var total: Int32 = 0
    var appNum: Int32 = 0
    if let income = theManager?.income {
      total = income.total
      appNum = income.appointmentsNumber
    }
    if let entryFee = theManager?.income?.fixedFee, entryFee > 0 {
      total += ( appNum * entryFee )
    }
    if total > 0 {
      totalIncomeLabel.text = "Total income: " + String(total) + " L.E."
    } else {
      totalIncomeLabel.text = "No income for this month."
    }
  }
  
  private func setupEntryFee() {
    if theManager?.income?.fixedFee != nil {
      fixedPaymentField.isHidden = true
      changeFeeBtn.isHidden = false
      entryFeeLabel.text = "Entry Fee: \((theManager?.income?.fixedFee)!) L.E."
      fixedPaymentField.text = ""
    }
  }
  
  fileprivate func fetchPayments() {
    displayData()
    guard theManager != nil else {return}
    let context = theManager?.managedObjectContext ?? container.viewContext
    let request: NSFetchRequest<IncomeAmount> = IncomeAmount.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    let idPredicate = NSPredicate(format: "id = %@", (theManager?.id)!)
    request.predicate = idPredicate
    do {
      payments = try context.fetch(request)
    } catch {
      print(error)
    }
  }
 
  @IBAction func changeFeesPressed(_ sender: UIButton) {
    if fixedPaymentField.isHidden {
      fixedPaymentField.isHidden = false
      fixedPaymentField.becomeFirstResponder()
      entryFeeLabel.text = "Entry Fee: "
      sender.isHidden = true
    }
  }
  
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if Int32.parse(fromString: textField.text!) == theManager?.income?.fixedFee {
      setupEntryFee()
      return
    }
    guard !(textField.text?.isEmpty)!, textField.text != "0" else {
      let alert = UIAlertController(title: "Remove Fee", message: "Do you want to remove the patient entry fee ?", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: {[weak self]_ in
        self?.confirmFee(value: 0)
      }))
      alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {[weak self]_ in
        self?.setupEntryFee()
      }))
      present(alert,animated: true)
      return
    }
    let alert = UIAlertController(title: "Confirm", message: "Do you want to set the fixed patient entry fee to \(textField.text!) ?", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {[weak self]_ in
      let fee = Int32.parse(fromString: textField.text!)
      self?.confirmFee(value: fee)
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {[weak self]_ in
      self?.setupEntryFee()
    }))
    present(alert,animated: true)
  }
  
  private func confirmFee(value: Int32) {
    theManager?.income?.fixedFee = value
    do {
      try container.viewContext.save()
      setupEntryFee()
      setupTotalIncome()
    } catch {
      print(error)
    }
  }
  
  @IBAction func nextMonth(_ sender: UIBarButtonItem) {
    getAnotherManager(next: true)
  }
  
  @IBAction func previousMonth(_ sender: UIBarButtonItem) {
    getAnotherManager(next: false)
  }
  
}


extension IncomeVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: IncomeCell.identifier) as? IncomeCell
    let amount = payments[indexPath.row]
    cell?.setupCell(name: amount.patientName!, income: amount)
    return cell!
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return payments.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 56
  }
  
}
