//
//  IngredientsItemTableViewCell.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/19/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit

final class IngredientsItemTableViewCell: TableViewCellBase {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    override func setupViews() {
        textLabel?.font = UIFont.systemFont(ofSize: 17)
        textLabel?.textColor = UIColor(.text)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
        detailTextLabel?.textColor = UIColor(.text)
        imageView?.image = UIImage(systemName: "checkmark",
                                   withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .bold))
        imageView?.tintColor = UIColor(.tint)
    }
}

extension IngredientsItemTableViewCell: CellViewModelProtocol {
    func config(with viewModel: IngredientsItemCellViewModel) {
        imageView?.isHidden = !viewModel.isContained
        textLabel?.text = viewModel.name
        detailTextLabel?.text = viewModel.priceText
    }
}
