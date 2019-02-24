//
//  AppointmentCell.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 11/25/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit

class AppointmentCell: UITableViewCell {

  static let identifier = "AppointmentCell"
    
  @IBOutlet weak var cellBG: UIView!
  @IBOutlet weak var patientName: UILabel!
  @IBOutlet weak var dateLbl: UILabel!
  @IBOutlet weak var procedureLbl: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    let shadowColor = #colorLiteral(red: 0.7128025293, green: 0.5533084869, blue: 0.2515522838, alpha: 1)
    cellBG.addShadow(location: .bottom, color: shadowColor, opacity: 1, radius: 4)
  }
  
  func setupCell(appointment: Appointment,fromCalendar: Bool) {
    dateLbl.text = DateFormatter.localizedString(from: appointment.date!, dateStyle: .medium, timeStyle: .short)
    procedureLbl.text = appointment.procedure
    if fromCalendar {
      patientName.isHidden = false
      patientName.text = appointment.thePatient?.name
    }
  }
  
}
