//
//  AppointmentsTableVC.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 11/14/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import CoreData

class AppointmentsTableVC: CoreDataTableViewController {
  
  var patient: Patient?
  var dateFromCalendar: Date!
  private var fetchedResultsController: NSFetchedResultsController<Appointment>?
  let container = AppDelegate.persistentContainer
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(UINib(nibName: "AppointmentCell", bundle: nil), forCellReuseIdentifier: AppointmentCell.identifier)
    if dateFromCalendar == nil {
      let rightButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(goToAdd))
      navigationItem.rightBarButtonItem = rightButton
    }
    tableView.contentInset = UIEdgeInsets(top: 5,left: 0,bottom: 5,right: 0)
    fetchAppointments()
  }
  
  override func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    super.controllerDidChangeContent(controller)
    adjustLastAndNextVisitDates()
  }
  
  private func adjustLastAndNextVisitDates() {
    guard let appointments = fetchedResultsController?.fetchedObjects else {return}
    let pastAppoints = appointments.filter({$0.date! < Date()})
    let futureAppoints = appointments.filter({$0.date! > Date()})
    if patient != nil, let context = patient?.managedObjectContext {
      if pastAppoints.count > 0 {
        patient?.lastVisitDate = pastAppoints[0].date
      } else {
        patient?.lastVisitDate = nil
      }
      if futureAppoints.count > 0 {
        patient?.nextVisitDate = futureAppoints.last?.date
      } else {
        patient?.nextVisitDate = nil
      }
      try? context.save()
    }
  }
  
  @objc private func goToAdd() {
    performSegue(withIdentifier: "toAddorEdit", sender: patient)
  }
  
  private func fetchAppointments() {
    let context = patient?.managedObjectContext ?? container.viewContext
    let request: NSFetchRequest<Appointment> = Appointment.fetchRequest()
    //    let selector = #selector(NSString.caseInsensitiveCompare(_:))
    request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    if dateFromCalendar != nil {
      let dateformatter = DateFormatter()
      dateformatter.dateFormat = "dd.MM.yy"
      let datePredicate = NSPredicate(format: "comparisonDate = %@", dateformatter.string(from: dateFromCalendar))
      request.predicate = datePredicate
    } else if patient != nil {
      let patientPredicate = NSPredicate(format: "thePatient = %@" , patient!)
      request.predicate = patientPredicate
    }
    fetchedResultsController = NSFetchedResultsController<Appointment>(
      fetchRequest: request,
      managedObjectContext: context,
      sectionNameKeyPath: nil,
      cacheName: nil
    )
    fetchedResultsController?.delegate = self
    do {
      try fetchedResultsController?.performFetch()
      adjustLastAndNextVisitDates()
      tableView.reloadData()
    } catch {
      print(error)
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentCell", for: indexPath) as? AppointmentCell
    if let appoint = fetchedResultsController?.object(at: indexPath) {
      cell?.setupCell(appointment: appoint, fromCalendar: (dateFromCalendar != nil))
    }
    return cell!
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let appoints = fetchedResultsController?.fetchedObjects {
      return appoints.count
    }
    return 0
  }

  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      if let appo = fetchedResultsController?.object(at: indexPath), let context = appo.managedObjectContext {
        context.delete(appo)
        do {
          try context.save()
        } catch {
          print(error)
        }
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
