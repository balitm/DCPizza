//
//  CartTotalTableViewCell.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit

class CartTotalTableViewCell: UITableViewCell {}

extension CartTotalTableViewCell: CellViewModelProtocol {
    func config(with viewModel: CartTotalCellViewModel) {
        detailTextLabel?.text = viewModel.priceText
        imageView?.alpha = 0.0
    }
}
