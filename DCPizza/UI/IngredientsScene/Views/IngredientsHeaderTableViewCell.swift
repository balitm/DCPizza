//
//  IngredientsHeaderTableViewCell.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/19/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit

final class IngredientsHeaderTableViewCell: SeparableTableViewCell {
    @IBOutlet weak var pizzaView: UIImageView!
}

extension IngredientsHeaderTableViewCell: CellViewModelProtocol {
    func config(with viewModel: IngredientsHeaderCellViewModel) {
        pizzaView.image = viewModel.image
    }
}
