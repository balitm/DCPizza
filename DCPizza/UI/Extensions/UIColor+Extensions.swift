//
//  UIColor+Extensions.swift
//
//  Copyright © 2016 Balázs Kilvády. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat((hex >> 16) & 0xff) / CGFloat(255.0),
                  green: CGFloat((hex >> 8) & 0xff) / CGFloat(255.0),
                  blue: CGFloat(hex & 0xff) / CGFloat(255.0),
                  alpha: alpha)
    }
}
