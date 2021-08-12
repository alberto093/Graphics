//
//  UIColor+.swift
//  Graphics-Demo
//
//  Created by Alberto Saltarelli on 15/06/21.
//  Copyright © 2021 Alberto Saltarelli. All rights reserved.
//

import UIKit.UIColor

extension UIColor {
    static let darkShadow = UIColor(red: 174, green: 174, blue: 192)
    static let lightShadow = UIColor.white
    static let demoBackground = UIColor(red: 236, green: 240, blue: 243)
    
    /// Create a color with [0, 255] components and alpha 1
    convenience init(red: UInt8, green: UInt8, blue: UInt8) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1)
    }
}
