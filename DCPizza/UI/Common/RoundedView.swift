//
//  RoundedView.swift
//  Creative
//
//  Created by Balázs Kilvády on 3/17/19.
//  Copyright © 2019 kil-dev. All rights reserved.
//

import UIKit

class RoundedView: UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            if let bc = layer.borderColor {
                return UIColor(cgColor: bc)
            } else {
                return UIColor.clear
            }
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }

    private func _init() {
        layer.round(with: 2)
    }
}

extension CALayer {
    func round(with radius: CGFloat) {
        cornerRadius = radius
    }
}
