//
//  AppointmentsTableViewController.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 11/14/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import CoreData

class AppointmentsTableViewController: UITableViewController {
  
  var patient: Patient?
  fileprivate var fetchedResultsController: NSFetchedResultsController<Appointment>?
  let container = AppDelegate.persistentContainer
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(UINib(nibName: "homeCell", bundle: nil), forCellReuseIdentifier: "HomeCell")
    tableView.register(UINib(nibName: "appointmentAddCell", bundle: nil), forCellReuseIdentifier: "appointmentAddCell")
    print(patient?.name ?? "???")
    updateUI()
  }
  
  private func updateUI() {
    guard let context = patient?.managedObjectContext else {return}
    let request: NSFetchRequest<Appointment> = Appointment.fetchRequest()
    //    let selector = #selector(NSString.caseInsensitiveCompare(_:))
    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
    //  request.predicate = NSPredicate(format: "" , )
    fetchedResultsController = NSFetchedResultsController<Appointment>(
      fetchRequest: request,
      managedObjectContext: context,
      sectionNameKeyPath: nil,
      cacheName: nil
    )
    fetchedResultsController?.delegate = self
    try? fetchedResultsController?.performFetch()
    tableView.reloadData()
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 1 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "appointmentAddCell", for: indexPath) as? appointmentAddCell
      cell?.patient = patient
      return cell!
    }
    let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as? homeCell
    if let appoint = fetchedResultsController?.object(at: indexPath) {
      if appoint.thePatient == patient {
        cell?.textLabel?.text = "Operator : \(appoint.theOperator!) ---- Assistant \(appoint.assistant!)"
        cell?.detailTextLabel?.text = appoint.date!
      }
    }
    return cell!
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let appoints = fetchedResultsController?.fetchedObjects?.filter({$0.thePatient == patient}), section == 0 {
      return appoints.count
    } else if section == 1 {
      return 1
    }
    return 0
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete && indexPath.section == 0 {
      if let appo = fetchedResultsController?.object(at: indexPath), let context = patient?.managedObjectContext {
        context.delete(appo)
        try? context.save()
      }
    }
  }
}
