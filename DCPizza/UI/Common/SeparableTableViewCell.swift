//
//  SeparableTableViewCell.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/19/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit

@IBDesignable
class SeparableTableViewCell: UITableViewCell {
    @IBInspectable var hasSeparator: Bool = true
    var defaultInsets: UIEdgeInsets?

    override func awakeFromNib() {
        super.awakeFromNib()

        defaultInsets = separatorInset
    }

    override func layoutSubviews() {
        if !hasSeparator {
            separatorInset = UIEdgeInsets(top: 0, left: bounds.width / 2, bottom: 0, right: bounds.width / 2)
        } else if let defaultInsets = defaultInsets {
            separatorInset = defaultInsets
        }
        super.layoutSubviews()
    }
}
