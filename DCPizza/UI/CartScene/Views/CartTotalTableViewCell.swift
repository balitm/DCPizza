//
//  CartTotalTableViewCell.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit

class CartTotalTableViewCell: TableViewCellBase {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    override func setupViews() {
        textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        textLabel?.textColor = UIColor(.text)
        detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        detailTextLabel?.textColor = UIColor(.text)
        imageView?.image = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 8))
    }
}

extension CartTotalTableViewCell: CellViewModelProtocol {
    func config(with viewModel: CartTotalCellViewModel) {
        textLabel?.text = "TOTAL"
        detailTextLabel?.text = viewModel.priceText
        imageView?.alpha = 0.0
    }
}
