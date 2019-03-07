//
//  Payment.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 3/3/19.
//  Copyright © 2019 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import CoreData

class Payment: NSManagedObject {
  
  override func prepareForDeletion() {
    totalExpenses?.total -= amount
    try? totalExpenses?.managedObjectContext?.save()
  }
  
}
