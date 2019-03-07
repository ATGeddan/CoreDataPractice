//
//  PaymentCell.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 3/4/19.
//  Copyright © 2019 Ahmed Eltabbal. All rights reserved.
//

import UIKit

class PaymentCell: UITableViewCell {

  static let identifier = "paymentCell"
  
  @IBOutlet weak var cellBG: UIView!
  @IBOutlet weak var categoryLbl: UILabel!
  @IBOutlet weak var dateLbl: UILabel!
  @IBOutlet weak var notesLbl: UILabel!
  @IBOutlet weak var amountLbl: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    let shadowColor = #colorLiteral(red: 0.7128025293, green: 0.5533084869, blue: 0.2515522838, alpha: 1)
    cellBG.addShadow(location: .bottom, color: shadowColor, opacity: 1, radius: 4)
  }

  func setupCell(payment: Payment) {
    guard let category = payment.category, let date = payment.date else {return}
    categoryLbl.text = "Category: \(category)"
    dateLbl.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
    amountLbl.text = "\(payment.amount) L.E."
    if let notes = payment.notes, notes != "" {
      notesLbl.text = payment.notes
    } else {
      notesLbl.text = ""
      notesLbl.frame.size.height = 0
    }
  }
    
}
