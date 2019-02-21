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
  
  func updateButtonUI(_ status: Int) {
    layer.cornerRadius = 15
    setTitleColor(.white, for: .normal)
    switch status {
    case 0:
      setTitleColor(.darkGray, for: .normal)
      layer.borderWidth = 1.5
      layer.borderColor = UIColor.darkGray.cgColor
      backgroundColor = .clear
    case 1:
      setTitleColor(.black, for: .normal)
      layer.borderWidth = 0
      backgroundColor = .yellow
    case 2:
      setTitleColor(.white, for: .normal)
      backgroundColor = .blue
    case 3:
      setTitleColor(.black, for: .normal)
      backgroundColor = .gray
    case 4:
      setTitleColor(.white, for: .normal)
      backgroundColor = .black
    case 5:
      backgroundColor = .brown
    case 6:
      backgroundColor = .purple
    case 7:
      backgroundColor = .red
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
      return "lr\(tag * -1)"
    case -16...(-9):
      return "ll\((tag + 8) * -1)"
    default:
      return "?"
    }
  }
  
}


extension UIButton {
  func rotate90() {
    UIView.animate(withDuration: 0.2) {[unowned self] in
      self.transform = CGAffineTransform(rotationAngle: 90 * (.pi / 180) )
      self.superview?.layoutIfNeeded()
    }
  }
  func rotate0() {
    UIView.animate(withDuration: 0.2) {[unowned self] in
      self.transform = CGAffineTransform(rotationAngle: 0 )
      self.superview?.layoutIfNeeded()
    }
  }
}
