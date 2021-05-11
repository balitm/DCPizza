//
//  DrinkTableViewCell.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/22/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit

class DrinkTableViewCell: TableViewCellBase {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    override func setupViews() {
        textLabel?.font = UIFont.systemFont(ofSize: 17)
        textLabel?.textColor = UIColor(.text)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
        detailTextLabel?.textColor = UIColor(.text)
        imageView?.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11))
        imageView?.tintColor = UIColor(.tint)
    }
}

extension DrinkTableViewCell: CellViewModelProtocol {
    func config(with viewModel: DrinkCellViewModel) {
        textLabel?.text = viewModel.name
        detailTextLabel?.text = viewModel.priceText
    }
}
