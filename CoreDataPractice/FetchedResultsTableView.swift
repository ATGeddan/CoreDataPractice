
//  FetchedResultsTableViewController.swift
//  Smashtag
//
//  Created by Michel Deiman on 27/03/2017.
//  Copyright © 2017 Michel Deiman. All rights reserved.
//

import UIKit
import CoreData

extension MyHomeTableVC: NSFetchedResultsControllerDelegate
{
  
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
