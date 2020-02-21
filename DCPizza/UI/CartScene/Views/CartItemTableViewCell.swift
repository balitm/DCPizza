//
//  CartItemTableViewCell.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit

class CartItemTableViewCell: UITableViewCell {}

extension CartItemTableViewCell: CellViewModelProtocol {
    func config(with viewModel: CartItemCellViewModel) {
        textLabel?.text = viewModel.name
        detailTextLabel?.text = viewModel.priceText
        imageView?.scalesLargeContentImage = true
        imageView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
    }
}
