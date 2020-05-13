//
//  MenuTableViewCell.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Combine
import AlamofireImage
import Domain

final class MenuTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var pizzaView: UIImageView!
    @IBOutlet weak var cartView: RoundedView!

    private weak var _tap: UITapGestureRecognizer!
    private let _tapEvent = PassthroughSubject<Void, Never>()
    private var _bag = Set<AnyCancellable>()

    override func awakeFromNib() {
        super.awakeFromNib()

        let tap = UITapGestureRecognizer(target: self, action: #selector(_actionTap))
        cartView.addGestureRecognizer(tap)
        _tap = tap
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        _bag = Set<AnyCancellable>()
    }

    @objc private func _actionTap() {
        DLog("sending tap")
        _tapEvent.send(())
    }
}

extension MenuTableViewCell: CellViewModelProtocol {
    func config(with viewModel: MenuCellViewModel) {
        nameLabel.text = viewModel.nameText
        ingredientsLabel.text = viewModel.ingredientsText
        priceLabel.text = viewModel.priceText
        if let url = viewModel.imageUrl {
            pizzaView.af_setImage(withURL: url)
        }

        _tapEvent
            .receive(subscriber: AnySubscriber(viewModel.tap))
    }
}
