//
//  MyHomeTableVCExtension.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 11/12/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import CoreData


// Specific for UIViewController
extension MyHomeTableVC: NSFetchedResultsControllerDelegate {
  
  public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
  {
    homeTableView.beginUpdates()
  }
  
  public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType)
  {
    switch type {
    case .insert: homeTableView.insertSections([sectionIndex], with: .fade)
    case .delete: homeTableView.deleteSections([sectionIndex], with: .fade)
    default: break
    }
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
  {
    switch type {
    case .insert:
      homeTableView.insertRows(at: [newIndexPath!], with: .fade)
    case .delete:
      homeTableView.deleteRows(at: [indexPath!], with: .fade)
    case .update:
      homeTableView.reloadRows(at: [indexPath!], with: .fade)
    case .move:
      homeTableView.deleteRows(at: [indexPath!], with: .fade)
      homeTableView.insertRows(at: [newIndexPath!], with: .fade)
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
  {
    homeTableView.endUpdates()
  }
  
}

// Generic for UITableViewController
extension UITableViewController: NSFetchedResultsControllerDelegate {
  
  public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
  {
    tableView.beginUpdates()
  }
  
  public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType)
  {
    switch type {
    case .insert: tableView.insertSections([sectionIndex], with: .fade)
    case .delete: tableView.deleteSections([sectionIndex], with: .fade)
    default: break
    }
  }
  
  public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
  {
    switch type {
    case .insert:
      tableView.insertRows(at: [newIndexPath!], with: .fade)
    case .delete:
      tableView.deleteRows(at: [indexPath!], with: .fade)
    case .update:
      tableView.reloadRows(at: [indexPath!], with: .fade)
    case .move:
      tableView.deleteRows(at: [indexPath!], with: .fade)
      tableView.insertRows(at: [newIndexPath!], with: .fade)
    }
  }
  
  public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
  {
    tableView.endUpdates()
  }
  
}
