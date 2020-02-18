//
//  MenuTableViewCell.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import AlamofireImage

final class MenuTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var pizzaView: UIImageView!
}

extension MenuTableViewCell: CellViewModelProtocol {
    func config(with viewModel: MenuCellViewModel) {
        nameLabel.text = viewModel.nameText
        ingredientsLabel.text = viewModel.ingredientsText
        priceLabel.text = viewModel.priceText
        if let url = viewModel.imageUrl {
            pizzaView.af_setImage(withURL: url)
        }
    }
}
