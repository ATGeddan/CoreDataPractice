//
//  IncomeCell.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 3/3/19.
//  Copyright © 2019 Ahmed Eltabbal. All rights reserved.
//

import UIKit

class IncomeCell: UITableViewCell {
  
  static let identifier = "incomeCell"
  
  @IBOutlet weak var cellBG: UIView!
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var feeLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    let shadowColor = #colorLiteral(red: 0.7128025293, green: 0.5533084869, blue: 0.2515522838, alpha: 1)
    cellBG.addShadow(location: .bottom, color: shadowColor, opacity: 1, radius: 4)
  }
  
  func setupCell(name: String, income: IncomeAmount) {
    nameLabel.text = name
    dateLabel.text = DateFormatter.localizedString(from: income.date!, dateStyle: .medium, timeStyle: .none)
    feeLabel.text = "\(income.amount) L.E."
  }
  
}
