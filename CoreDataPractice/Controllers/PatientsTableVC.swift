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
    tableView.register(UINib(nibName: "PatientCell", bundle: nil), forCellReuseIdentifier: "PatientCell")
    let rightAddButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPatient))
    let rightSearchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchClicked))
    navigationItem.rightBarButtonItems = [rightAddButton,rightSearchButton]
    
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
    searchController.searchBar.placeholder = "Search Patients"
    searchController.searchBar.tintColor = .white
    searchController.searchBar.barTintColor = .white
    navigationItem.hidesSearchBarWhenScrolling = true
    navigationItem.searchController = searchController
    definesPresentationContext = true
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PatientCell", for: indexPath) as? PatientCell
    if isFiltering {
      let patient = filteredPatients[indexPath.row]
      if patient.lastVisitDate != nil {
        let dateTxt = DateFormatter.localizedString(from: patient.lastVisitDate!, dateStyle: .medium, timeStyle: .none)
        cell?.dateLabel.text = "Last Visit : \(dateTxt)"
      } else {
        cell?.dateLabel.text = "Last Visit : -- -- ----"
      }
      cell?.nameLabel.text = patient.name!
      cell?.ageLabel.text = String(patient.age)
      cell?.phoneLabel.text = patient.phone!
      switch patient.status {
      case 0:
        cell?.statusImage.image = UIImage(named: "Logo")
      case 1:
        cell?.statusImage.image = UIImage(named: "New")
      case 2:
        cell?.statusImage.image = UIImage(named: "High risk")
      case 3:
        cell?.statusImage.image = UIImage(named: "VIP")
      default:
        break
      }
    } else {
      if let patient = fetchedResultsController?.object(at: indexPath) {
        if patient.lastVisitDate != nil {
          let dateTxt = DateFormatter.localizedString(from: patient.lastVisitDate!, dateStyle: .medium, timeStyle: .none)
          cell?.dateLabel.text = "Last Visit : \(dateTxt)"
        } else {
          cell?.dateLabel.text = "Last Visit : -- -- ----"
        }
        cell?.nameLabel.text = patient.name!
        cell?.ageLabel.text = String(patient.age)
        cell?.phoneLabel.text = patient.phone!
        switch patient.status {
        case 0:
          cell?.statusImage.image = UIImage(named: "Logo")
        case 1:
          cell?.statusImage.image = UIImage(named: "New")
        case 2:
          cell?.statusImage.image = UIImage(named: "High risk")
        case 3:
          cell?.statusImage.image = UIImage(named: "VIP")
        default:
          break
        }
      }
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
    return 165
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? PatientVC, let thePatient = sender as? Patient {
      destination.patient = thePatient
    }
  }
  
}
