//
//  Picture.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 11/18/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit
import CoreData

class Picture: NSManagedObject {
  
  func createNewPicture(data: Data,appointment: Appointment) {
    id = UUID().uuidString
    date = Date()
    theAppointment = appointment
    thePatient = appointment.thePatient
    picData = data
  }
  
}
