//
//  IngredientsHeaderTableViewCell.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/19/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Combine

final class IngredientsHeaderTableViewCell: SeparableTableViewCell {
    @IBOutlet weak var pizzaView: UIImageView!

    private var _bag = Set<AnyCancellable>()
}

extension IngredientsHeaderTableViewCell: CellViewModelProtocol {
    func config(with viewModel: IngredientsHeaderCellViewModel) {
        _bag = [
            viewModel.image
                .assign(to: \.image, on: pizzaView),
        ]
    }
}
