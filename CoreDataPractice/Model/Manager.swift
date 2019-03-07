//
//  Manager.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 3/1/19.
//  Copyright © 2019 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import CoreData

class Manager: NSManagedObject {
  
  var monthString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMMM yyyy"
    if let date = month {
      return formatter.string(from: date)
    }
    return "Date missing"
  }
  
  static var thisMonthPredicate: NSPredicate {

    return Manager.createMonthPredicate(date: Date())
  }
  
  static func createMonthPredicate(date: Date) -> NSPredicate {
    let calendar = Calendar.current
    let chosenDateComponents = calendar.dateComponents([.year,.month], from: date)
    
    let selectedMonth = chosenDateComponents.month
    let selectedYear = chosenDateComponents.year
    var components = DateComponents()
    components.month = selectedMonth
    components.year = selectedYear
    let startDateOfMonth = Calendar.current.date(from: components)
    
    components.year = 0
    components.month = 1
    components.day = -1
    let endDateOfMonth = Calendar.current.date(byAdding: components, to: startDateOfMonth!)
    
    return NSPredicate(format: "%K >= %@ && %K <= %@", "month", startDateOfMonth! as NSDate, "month", endDateOfMonth! as NSDate)
  }

  func newMonthManager(context: NSManagedObjectContext) {
    let newIncome = Income(context: context)
    let newExpenses = Expenses(context: context)
    month = Date()
    income = newIncome
    expense = newExpenses
    id = UUID().uuidString
  }
  
  static func getManagerForDate(date: Date, context: NSManagedObjectContext) -> Manager? {
    let request: NSFetchRequest<Manager> = Manager.fetchRequest()
    request.predicate = Manager.createMonthPredicate(date: date)
    do {
      let managers = try context.fetch(request)
      if let manager = managers.first {
        return manager
      }
    } catch {
      print(error)
    }
    return nil
  }
  
}
