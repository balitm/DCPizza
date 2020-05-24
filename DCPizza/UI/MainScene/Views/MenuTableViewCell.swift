//
//  MenuTableViewCell.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Combine
import Domain

final class MenuTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var pizzaView: UIImageView!
    @IBOutlet weak var cartView: RoundedView!

    private weak var _tap: UITapGestureRecognizer!
    private var _bag = Set<AnyCancellable>()

    override func awakeFromNib() {
        super.awakeFromNib()

        let tap = UITapGestureRecognizer()
        cartView.addGestureRecognizer(tap)
        _tap = tap
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        pizzaView.image = nil
        _bag = Set<AnyCancellable>()
    }
}

extension MenuTableViewCell: CellViewModelProtocol {
    func config(with viewModel: MenuCellViewModel) {
        nameLabel.text = viewModel.nameText
        ingredientsLabel.text = viewModel.ingredientsText
        priceLabel.text = viewModel.priceText

        // Image updater.
        viewModel.image
            .assign(to: \.image, on: pizzaView)
            .store(in: &_bag)

        // Tap event.
        _tap.cmb.event()
            .sink(receiveValue: {
                viewModel.tap.send(())
            })
            .store(in: &_bag)
    }
}
