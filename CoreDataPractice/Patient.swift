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
  
  
  func savePatientWithInfo(info:[String:String] ,context: NSManagedObjectContext) {
    if let name2 = info["name"] {
      name = name2
    }
    if let age2 = info["age"] {
      age = age2
    }
    if let gender2 = info["gender"] {
      gender = gender2
    }
    date = Date()
    do {
      try context.save()
      print("Saved the Patient Successfuly")
    } catch {
      print(error)
    }
  }
  
}
