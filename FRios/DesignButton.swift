//
//  DesignButton.swift
//  MomoApp
//
//  Created by Huỳnh Lê Minh Trí on 5/22/17.
//  Copyright © 2017 cusc. All rights reserved.
//

//import Cocoa
import UIKit
@IBDesignable

class DesignButton: UIButton {
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
}
