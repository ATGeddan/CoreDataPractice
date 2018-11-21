//
//  PatientsTableVC.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 11/12/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import CoreData

class PatientsTableVC: CoreDataTableViewController {
  
  private let container = AppDelegate.persistentContainer
  
  private var fetchedResultsController: NSFetchedResultsController<Patient>?
  
  override func viewDidLoad() {
    tableView.register(UINib(nibName: "PatientCell", bundle: nil), forCellReuseIdentifier: "PatientCell")
    let rightButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPatient))
    navigationItem.rightBarButtonItem = rightButton
    updateUI()
  }
  
  @objc private func addPatient() {
    performSegue(withIdentifier: "addPatient", sender: nil)
  }
  
  private func updateUI()  {
    let context = container.viewContext
    let request: NSFetchRequest<Patient> = Patient.fetchRequest()
//    let selector = #selector(NSString.caseInsensitiveCompare(_:))
    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
//  request.predicate = NSPredicate(format: "" , )
    fetchedResultsController = NSFetchedResultsController<Patient>(
      fetchRequest: request,
      managedObjectContext: context,
      sectionNameKeyPath: nil,
      cacheName: nil
    )
    fetchedResultsController?.delegate = self
    try? fetchedResultsController?.performFetch()
    tableView.reloadData()
    
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell", for: indexPath)
    if let patient = fetchedResultsController?.object(at: indexPath) {
      cell.textLabel?.text = "\(patient.name!) - Gender : \(patient.gender!) "
      cell.detailTextLabel?.text = "Age : \(patient.age)"
    }
    return cell
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let patients = fetchedResultsController?.fetchedObjects {
      return patients.count
    } else {
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    let context = container.viewContext
    if editingStyle == .delete {
      if let patient = fetchedResultsController?.object(at: indexPath) {
        context.delete(patient)
        try? context.save()
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let patient = fetchedResultsController?.object(at: indexPath) {
      performSegue(withIdentifier: "chosePatient", sender: patient)
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? AppointmentsTableViewController, let thePatient = sender as? Patient {
      destination.patient = thePatient
    }
  }
  
}
