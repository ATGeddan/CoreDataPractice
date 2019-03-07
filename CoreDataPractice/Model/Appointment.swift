//
//  Appointment.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 11/14/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import CoreData

class Appointment: NSManagedObject {
  
  override func prepareForDeletion() {
    let context = AppDelegate.context
    let manager = Manager.getManagerForDate(date: date!, context: context)
    manager?.income?.appointmentsNumber -= 1
    try? context.save()
  }
  
}
