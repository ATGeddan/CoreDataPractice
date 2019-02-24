//
//  PatientCell.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 11/12/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit

class PatientCell: UITableViewCell {

  static let identifier = "PatientCell"
  
  @IBOutlet weak var cellBG: UIView!
  @IBOutlet weak var statusImage: UIImageView!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var ageLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    let shadowColor = #colorLiteral(red: 0.7128025293, green: 0.5533084869, blue: 0.2515522838, alpha: 1)
    cellBG.addShadow(location: .bottom, color: shadowColor, opacity: 1, radius: 4)
  }
 
  func setupCell(patient: Patient) {
    let lastVisitString = patient.lastVisitDate != nil ? DateFormatter.localizedString(from: patient.lastVisitDate!, dateStyle: .medium, timeStyle: .none) : "--/--/----"
    dateLabel.text = "Last Visit: \(lastVisitString)"
    nameLabel.text = patient.name
    let ageInYears = calculateAge(birthDate: patient.birth!)
    if ageInYears > 0 {
      ageLabel.text = "\(calculateAge(birthDate: patient.birth!)) Years"
    } else {
      ageLabel.text = "\(calculateMonths(patient.birth!)) Months"
    }
    switch patient.status {
    case 1:
      statusImage.image = patient.isStillNew ? UIImage(named: "New") : UIImage(named: "Logo")
    case 2:
      statusImage.image = UIImage(named: "High risk")
    case 3:
      statusImage.image = UIImage(named: "VIP")
    default:
      break
    }
  }
  
  private func calculateMonths(_ date: Date) -> Int {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.month], from: date)
    return components.month!
  }
  
}
