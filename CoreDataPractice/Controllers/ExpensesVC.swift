//
//  ExpensesVC.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 3/3/19.
//  Copyright © 2019 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import CoreData

class ExpensesVC: UIViewController {

  @IBOutlet weak var expensesTableView: UITableView!
  @IBOutlet weak var totalLabel: UILabel!
  
  lazy var slideInTransitioningDelegate = SlideInPresentationManager()
  private let container = AppDelegate.persistentContainer
  private var theManager: Manager?
  private var chosenDate = Date()
  fileprivate var payments = [Payment]() {
    didSet { expensesTableView.reloadData() }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    expensesTableView.register(UINib(nibName: "PaymentCell", bundle: nil), forCellReuseIdentifier: PaymentCell.identifier)
    expensesTableView.rowHeight = UITableView.automaticDimension
    expensesTableView.estimatedRowHeight = 48
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    navigationItem.title = formatter.string(from: Date())
    fetchManagerAndPayments(forDate: chosenDate)
  }

  @IBAction func nextMonth(_ sender: UIBarButtonItem) {
    getAnotherManager(next: true)
  }

  @IBAction func previousMonth(_ sender: UIBarButtonItem) {
    getAnotherManager(next: false)
  }
  
  fileprivate func fetchManagerAndPayments(forDate date: Date) {
    let context = container.viewContext
    if let manager = Manager.getManagerForDate(date: date, context: context) {
      theManager = manager
      fetchPayments()
    } else {
      payments = []
      theManager = nil
    }
    setTotal()
  }
  
  fileprivate func getAnotherManager(next: Bool) {
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
  
  private func fetchPayments() {
    let context = theManager?.managedObjectContext ?? container.viewContext
    let request: NSFetchRequest<Payment> = Payment.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    let idPredicate = NSPredicate(format: "id = %@", (theManager?.id)!)
    request.predicate = idPredicate
    do {
      payments = try context.fetch(request)
    } catch {
      print(error)
    }
  }
  
  private func setTotal() {
    if let total = theManager?.expense?.total, total > 0 {
      totalLabel.text = "Total: \(total) L.E."
    } else {
      totalLabel.text = "No Expenses on this month."
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let dest = segue.destination as? AddPaymentVC {
      slideInTransitioningDelegate.direction = .bottom
      dest.transitioningDelegate = slideInTransitioningDelegate
      dest.modalPresentationStyle = .custom
      dest.theManager = theManager
      dest.chosenDate = chosenDate
      dest.addedNewPayment = {[unowned self] payment in
        self.payments.insert(payment, at: 0)
        self.setTotal()
      }
    }
  }
  
}


extension ExpensesVC: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return payments.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: PaymentCell.identifier, for: indexPath) as? PaymentCell
    cell?.setupCell(payment: payments[indexPath.row])
    return cell!
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let context = payments[indexPath.row].managedObjectContext ?? AppDelegate.context
      context.delete(payments[indexPath.row])
      do {
        try context.save()
        payments.remove(at: indexPath.row)
        setTotal()
      } catch {
        print(error)
      }
    }
  }
  
}
