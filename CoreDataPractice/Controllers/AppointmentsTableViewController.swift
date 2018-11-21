//
//  AppointmentsTableViewController.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 11/14/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import CoreData

class AppointmentsTableViewController: CoreDataTableViewController {
  
  var patient: Patient?
  private var fetchedResultsController: NSFetchedResultsController<Appointment>?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(UINib(nibName: "PatientCell", bundle: nil), forCellReuseIdentifier: "PatientCell")
    let rightButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(goToAdd))
    navigationItem.rightBarButtonItem = rightButton
    updateUI()
  }
  
  @objc private func goToAdd() {
    performSegue(withIdentifier: "toAddorEdit", sender: patient)
  }
  
  private func updateUI() {
    guard let thePatient = patient else {return}
    guard let context = thePatient.managedObjectContext else {return}
    let request: NSFetchRequest<Appointment> = Appointment.fetchRequest()
    //    let selector = #selector(NSString.caseInsensitiveCompare(_:))
    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
    request.predicate = NSPredicate(format: "thePatient = %@" , thePatient)
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell", for: indexPath) as? PatientCell
    if let appoint = fetchedResultsController?.object(at: indexPath) {
      cell?.textLabel?.text = "Operator : \(appoint.theOperator!) ---- Assistant \(appoint.assistant!)"
      cell?.detailTextLabel?.text = DateFormatter.localizedString(from: appoint.date ?? Date(), dateStyle: .short, timeStyle: .short)
    }
    return cell!
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let appoints = fetchedResultsController?.fetchedObjects {
      return appoints.count
    }
    return 1
  }

  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete && indexPath.section == 0 {
      if let appo = fetchedResultsController?.object(at: indexPath), let context = patient?.managedObjectContext {
        context.delete(appo)
        try? context.save()
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let appoint = fetchedResultsController?.object(at: indexPath) {
      performSegue(withIdentifier: "selectedAppoint", sender: appoint)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let dest = segue.destination as? AddOrEditAppointmentVC, let thePatient = sender as? Patient {
      dest.patient = thePatient
    }
    if let dest2 = segue.destination as? AppointmentVC, let theAppoint = sender as? Appointment {
      dest2.appointment = theAppoint
    }
  }
}
