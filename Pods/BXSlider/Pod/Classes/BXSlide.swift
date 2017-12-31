//
//  BXSlide.swift
//  Pods
//
//  Created by Haizhen Lee on 16/4/19.
//
//

import Foundation
import UIKit


public protocol BXSlide{
  var bx_image:UIImage?{ get }
  var bx_imageURL:URL?{ get }
  var bx_title:String?{ get }
}

public extension BXSlide{
  public var bx_duration:TimeInterval{
    return 5.0
  }
  var bx_image:UIImage?{ return nil }
  var bx_imageURL:URL?{ return nil }
  var bx_title:String?{ return nil }
}

extension URL:BXSlide{
  public var bx_imageURL:URL?{
    return self
  }
}

extension UIImage:BXSlide{
  public var bx_image:UIImage?{
    return self
  }
}

open class BXSimpleSlide:BXSlide{
  open let image:UIImage?
  open let imageURL:URL?
  open let title:String?
  
  open var bx_image:UIImage?{ return image }
  open var bx_imageURL:URL?{ return imageURL  }
  open var bx_title:String?{ return title }
  open var bx_duration:TimeInterval{ return 5.0 }
  
  public  init(image:UIImage,title:String?=nil){
    self.image = image
    self.title = title
    self.imageURL = nil
  }
  
  public init(imageURL:URL,title:String?=nil){
    self.image = nil
    self.title = title
    self.imageURL = imageURL
  }
  
  
  
}
