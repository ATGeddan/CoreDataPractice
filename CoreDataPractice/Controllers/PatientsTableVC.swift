//
//  PatientsTableVC.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 11/12/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import CoreData

class PatientsTableVC: CoreDataTableViewController, UISearchResultsUpdating {

  
  
  private let container = AppDelegate.persistentContainer
  
  private var fetchedResultsController: NSFetchedResultsController<Patient>?
  let searchController = UISearchController(searchResultsController: nil)
  var filteredPatients = [Patient]()
  var isFiltering = false { didSet { tableView.reloadData() } }
  
  override func viewDidLoad() {
    tableView.register(UINib(nibName: "PatientCell", bundle: nil), forCellReuseIdentifier: PatientCell.identifier)
    let rightAddButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPatient))
    let rightSearchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchClicked))
    navigationItem.rightBarButtonItems = [rightAddButton,rightSearchButton]
    tableView.contentInset = UIEdgeInsets(top: 5,left: 0,bottom: 5,right: 0)
    setupSearchController()
    fetchPatients()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(true)
    searchController.isActive = false
  }

  @objc private func searchClicked() {
    searchController.isActive = true
  }
  
  func updateSearchResults(for searchController: UISearchController) {
    if !(searchController.searchBar.text?.isEmpty)! {
      let thePredicate1 = NSPredicate(format: "name contains[c] %@", searchController.searchBar.text!)
      let thePredicate2 = NSPredicate(format: "name like %@", searchController.searchBar.text!)
      let orPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [thePredicate1,thePredicate2])
      let patients2 = fetchedResultsController?.fetchedObjects as NSArray?
      filteredPatients = patients2?.filtered(using: orPredicate) as! [Patient]
      isFiltering = true
    } else {
      isFiltering = false
      
    }
  }
  
  @objc private func addPatient() {
    performSegue(withIdentifier: "addPatient", sender: nil)
  }
  
  private func fetchPatients()  {
    let context = container.viewContext
    let request: NSFetchRequest<Patient> = Patient.fetchRequest()
//    let selector = #selector(NSString.caseInsensitiveCompare(_:))
    let sort1 = NSSortDescriptor(key: "date", ascending: true)
    let sort2 = NSSortDescriptor(key: "status", ascending: false)
    request.sortDescriptors = [sort2,sort1]
    fetchedResultsController = NSFetchedResultsController<Patient>(
      fetchRequest: request,
      managedObjectContext: context,
      sectionNameKeyPath: nil,
      cacheName: nil
    )
    fetchedResultsController?.delegate = self
    do {
      try fetchedResultsController?.performFetch()
      tableView.reloadData()
    } catch {
      print(error)
    }
  }
  
  private func setupSearchController() {
    searchController.searchResultsUpdater = self
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.searchBarStyle = .minimal
    searchController.searchBar.barStyle = .blackOpaque
    searchController.searchBar.placeholder = "Search Patients"
    searchController.searchBar.tintColor = #colorLiteral(red: 0.07090329379, green: 0.1490469873, blue: 0.1254850328, alpha: 1)
    navigationItem.hidesSearchBarWhenScrolling = true
    navigationItem.searchController = searchController
    definesPresentationContext = true
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell", for: indexPath) as? PatientCell
    if let thePatient = fetchedResultsController?.object(at: indexPath) {
      let patient = !isFiltering ? thePatient : filteredPatients[indexPath.row]
      cell?.setupCell(patient: patient)
    }
    return cell!
  }

  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isFiltering {
      return filteredPatients.count
    }
    if let patients = fetchedResultsController?.fetchedObjects {
      return patients.count
    } else {
      return 0
    }
  }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if isFiltering {
      performSegue(withIdentifier: "chosePatient", sender: filteredPatients[indexPath.row])
    } else {
      if let patient = fetchedResultsController?.object(at: indexPath) {
        performSegue(withIdentifier: "chosePatient", sender: patient)
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 93
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? PatientVC, let thePatient = sender as? Patient {
      destination.patient = thePatient
    }
  }
  
}
