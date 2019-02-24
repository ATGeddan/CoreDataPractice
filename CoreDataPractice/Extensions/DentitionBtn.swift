//
//  DentitionBtn.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 12/26/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit

class DentitionBtn: UIButton {
  
  var status = 0
  var type: toothType = .permenant
  
  enum toothType {
    case permenant
    case decidious
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    if tag > 100 || tag < -100 {
      type = .decidious
    }
  }
  
  func updateButtonUI(_ status: Int) {
    let color = #colorLiteral(red: 0.07090329379, green: 0.1490469873, blue: 0.1254850328, alpha: 1)
    layer.cornerRadius = 15
    setTitleColor(.white, for: .normal)
    switch status {
    case 0:
      setTitleColor(color, for: .normal)
      layer.borderWidth = 1.5
      layer.borderColor = color.cgColor
      backgroundColor = .clear
    case 1:
      setTitleColor(color, for: .normal)
      layer.borderWidth = 0
      backgroundColor = .yellow
    case 2:
      setTitleColor(.white, for: .normal)
      backgroundColor = .blue
    case 3:
      setTitleColor(color, for: .normal)
      backgroundColor = .gray
    case 4:
      setTitleColor(.white, for: .normal)
      backgroundColor = .black
    case 5:
      backgroundColor = .red
    case 6:
      backgroundColor = .purple
    case 7:
      backgroundColor = .brown
    case 8:
      backgroundColor = .orange
    default:
      break
    }
  }
  
  func getToothName() -> String {
    switch tag {
    case 1...8:
      return "ur\(tag)"
    case 9...16:
      return "ul\(tag - 8)"
    case -8...(-1):
      return "lr\(-tag)"
    case -16...(-9):
      return "ll\(-(tag + 8))"
    case 101...105:
      return "dur\(tag - 100)"
    case 106...110:
      return "dul\(tag - 105)"
    case -105...(-101):
      return "dlr\(-(tag + 100))"
    case -110...(-106):
      return "dll\(-(tag + 105))"
    default:
      return "?"
    }
  }
  
}
