//
//  CachingImagesExtension.swift
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
