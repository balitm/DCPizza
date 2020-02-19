//
//  IngredientsItemTableViewCell.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/19/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit

final class IngredientsItemTableViewCell: UITableViewCell {}

extension IngredientsItemTableViewCell: CellViewModelProtocol {
    func config(with viewModel: IngredientsItemCellViewModel) {
        imageView?.isHidden = !viewModel.isContained
        textLabel?.text = viewModel.name
        detailTextLabel?.text = viewModel.priceText
    }
}
