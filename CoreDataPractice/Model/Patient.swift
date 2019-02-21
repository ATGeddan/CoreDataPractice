//
//  Patient.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 11/11/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import CoreData

class Patient: NSManagedObject {
  
  var isStillNew: Bool {
    let calendar = Calendar.current
    let presentDateComponents = calendar.dateComponents([.year,.month,.day], from: Date())
    let patientStartingDateComponents = calendar.dateComponents([.year,.month,.day], from: date!)
    
    let sameMonth = presentDateComponents.month == patientStartingDateComponents.month
    let noMoreThanSevenDays = presentDateComponents.day! - patientStartingDateComponents.day! < 7
    
    let nextMonth = presentDateComponents.month! - patientStartingDateComponents.month! == 1
    let nextYear = presentDateComponents.year! - patientStartingDateComponents.year! == 1
    let earlyNextMonth = (30 - patientStartingDateComponents.day!) + presentDateComponents.day! < 7
    
    if (sameMonth && noMoreThanSevenDays) || (nextMonth && earlyNextMonth) || (nextYear && earlyNextMonth) {
      return true
    }
    return false
  }
  
}
