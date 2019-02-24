//
//  Extensions.swift
//  CoreDataPractice
//
//  Created by Ahmed Eltabbal on 11/19/18.
//  Copyright © 2018 Ahmed Eltabbal. All rights reserved.
//

import UIKit


let imageCache = NSCache<AnyObject, AnyObject>()


extension UIImageView {
  public func imageUsingCacheFromDatabase(key: String) {
    if let cachedImage = imageCache.object(forKey: key as AnyObject) as? UIImage {
      self.image = cachedImage
      return
    }
    imageCache.setObject(self.image!, forKey: key as AnyObject)
  }
  
}


extension UIViewController {
  
  func presentBasicAlert(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Got it", style: .default, handler: nil))
    present(alert,animated: true)
  }
  
}

func calculateAge(birthDate: Date) -> Int {
  let calendar = Calendar.current
  let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
  return ageComponents.year!
}

enum PresentationDirection: String {
  case bottom
  case top
  case right
  case left
}

extension UIView {
  func addShadow(location: PresentationDirection, color: UIColor = .black, opacity: Float = 0.5, radius: CGFloat = 5.0) {
    switch location {
    case .bottom:
      addShadow(offset: CGSize(width: 0, height: 3), color: color, opacity: opacity, radius: radius)
    case .top:
      addShadow(offset: CGSize(width: 0, height: -3), color: color, opacity: opacity, radius: radius)
    case .right:
      addShadow(offset: CGSize(width: 3, height: 0), color: color, opacity: opacity, radius: radius)
    case .left:
      addShadow(offset: CGSize(width: -3, height: 0), color: color, opacity: opacity, radius: radius)
    }
    
  }
  
  func addShadow(offset: CGSize, color: UIColor = .black, opacity: Float = 0.25, radius: CGFloat = 5.0) {
    self.layer.masksToBounds = false
    self.layer.shadowColor = color.cgColor
    self.layer.shadowOffset = offset
    self.layer.shadowOpacity = opacity
    self.layer.shadowRadius = radius
  }
}
