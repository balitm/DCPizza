//
//  CartItemTableViewCell.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit

class CartItemTableViewCell: TableViewCellBase {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    override func setupViews() {
        textLabel?.font = UIFont.systemFont(ofSize: 17)
        textLabel?.textColor = UIColor(.text)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
        detailTextLabel?.textColor = UIColor(.text)
        imageView?.image = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 8))
        imageView?.tintColor = UIColor(.tint)
    }
}

extension CartItemTableViewCell: CellViewModelProtocol {
    func config(with viewModel: CartItemCellViewModel) {
        textLabel?.text = viewModel.name
        detailTextLabel?.text = viewModel.priceText
    }
}
