//
//  SmashTweetersTableViewController.swift
//  Smashtag
//
//  Created by Michel Deiman on 26/03/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//
import UIKit
import CoreData

class MyHomeTableVC: UIViewController, UITableViewDataSource, UITableViewDelegate
{
  
  @IBOutlet weak var genderSwitch: UISwitch!
  @IBOutlet weak var ageField: UITextField!
  @IBOutlet weak var nameField: UITextField!
  @IBOutlet weak var homeTableView: UITableView!
  
  let container = AppDelegate.persistentContainer
  
  fileprivate var fetchedResultsController: NSFetchedResultsController<Patient>?
  
  override func viewDidLoad() {
    homeTableView.register(UINib(nibName: "homeCell", bundle: nil), forCellReuseIdentifier: "HomeCell")
    homeTableView.dataSource = self
    homeTableView.delegate = self
    updateUI()
  }
  
  func updateUI()  {
    let context = container.viewContext
    let request: NSFetchRequest<Patient> = Patient.fetchRequest()
    let selector = #selector(NSString.caseInsensitiveCompare(_:))
    request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: selector)]
//  request.predicate = NSPredicate(format: "" , )
    fetchedResultsController = NSFetchedResultsController<Patient>(
      fetchRequest: request,
      managedObjectContext: context,
      sectionNameKeyPath: nil,
      cacheName: nil
    )
    fetchedResultsController?.delegate = self
    try? fetchedResultsController?.performFetch()
    homeTableView.reloadData()
    
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath)
    if let patient = fetchedResultsController?.object(at: indexPath) {
      cell.textLabel?.text = "\(patient.name!) - Gender : \(patient.gender!) "
      cell.detailTextLabel?.text = "Age : \(patient.age!)"
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    if let patients = fetchedResultsController?.fetchedObjects {
      return patients.count
    } else {
      return 1
    }
  }
  
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    let context = container.viewContext
    if editingStyle == .delete {
      if let patient = fetchedResultsController?.object(at: indexPath) {
        context.delete(patient)
        try? context.save()
      }
    }
  }
  
  @IBAction func addPatientClicked(_ sender: UIButton) {
    let context = container.viewContext
    if !(nameField.text?.isEmpty)! && !(ageField.text?.isEmpty)! {
      var patient = Patient(context: context)
      var gender: String {
        if genderSwitch.isOn {
          return "Male"
        } else {
          return "Female"
        }
      }
      let info = ["name":nameField.text!,
                  "age":ageField.text!,
                  "gender":gender]
      patient.savePatientWithInfo(info: info, context: container.viewContext)
    }
  }
  
}
