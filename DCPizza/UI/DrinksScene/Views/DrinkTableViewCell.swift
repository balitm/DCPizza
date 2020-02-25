//
//  DrinkTableViewCell.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/22/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit

class DrinkTableViewCell: UITableViewCell {}

extension DrinkTableViewCell: CellViewModelProtocol {
    func config(with viewModel: DrinkCellViewModel) {
        textLabel?.text = viewModel.name
        detailTextLabel?.text = viewModel.priceText
    }
}
