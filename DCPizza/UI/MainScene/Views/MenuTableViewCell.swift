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
import Stevia

final class MenuTableViewCell: TableViewCellBase {
    private let _nameLabel = UILabel()
    private let _ingredientsLabel = UILabel()
    private let _priceLabel = UILabel()
    private let _pizzaView = UIImageView()
    private let _activityView = UIActivityIndicatorView(style: .large)

    private weak var _tap: UITapGestureRecognizer!
    private var _bag = Set<AnyCancellable>()

    override func setupViews() {
        let bgView = UIImageView(image: UIImage(imageLiteralResourceName: "bg_wood"))
        let cartView = RoundedView()
        let tap = UITapGestureRecognizer()
        let stackView = UIStackView(arrangedSubviews: [_nameLabel, _ingredientsLabel])
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        let innerView = UIView()
        let priceImageView = UIImageView(image: UIImage(imageLiteralResourceName: "ic_cart_button"))

        cartView.addGestureRecognizer(tap)
        _tap = tap
        contentView.clipsToBounds = true

        // Setup views.
        _activityView.style { a in
            a.hidesWhenStopped = true
            a.color = .black
        }
        _pizzaView.style { v in
            v.contentMode = .scaleAspectFill
            v.clipsToBounds = true
        }
        _nameLabel.style { l in
            l.font = UIFont.boldSystemFont(ofSize: 24)
            l.textColor = UIColor(.text)
        }
        _ingredientsLabel.style { l in
            l.font = UIFont.systemFont(ofSize: 14)
            l.textColor = UIColor(.text)
            l.numberOfLines = 0
        }
        stackView.style { s in
            s.axis = .vertical
            s.alignment = .leading
            s.distribution = .fill
        }
        cartView.style { v in
            v.backgroundColor = UIColor(.button)
        }
        priceImageView.style { v in
            v.tintColor = UIColor(.price)
        }
        _priceLabel.style { l in
            l.font = UIFont.boldSystemFont(ofSize: 16)
            l.textColor = UIColor(.price)
        }
        bgView.style { v in
            v.contentMode = .scaleAspectFill
        }

        // Subviews.
        contentView.subviews {
            bgView
            _activityView
            _pizzaView
            effectView
        }
        effectView.contentView.subviews {
            innerView
        }
        innerView.subviews {
            stackView
            cartView
        }
        cartView.subviews {
            priceImageView
            _priceLabel
        }

        // Layouts.
        _pizzaView.fillContainer().height(179)
        bgView.height(128)
        bgView.Leading == _pizzaView.Leading
        bgView.Top == _pizzaView.Top
        bgView.Width == _pizzaView.Width

        effectView.fillHorizontally().bottom(0)
        innerView.fillContainer()

        stackView.leading(12).fillVertically(padding: 12)

        cartView.Leading == stackView.Trailing + 30
        cartView.bottom(12).trailing(12)

        priceImageView.leading(8).width(14).height(14).bottom(7)

        _priceLabel.Leading == priceImageView.Trailing + 4
        _priceLabel.fillVertically(padding: 4).trailing(8)

        _activityView.width(80).height(80).top(20).centerHorizontally()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        _pizzaView.image = nil
        _bag = Set<AnyCancellable>()
    }
}

extension MenuTableViewCell: CellViewModelProtocol {
    func config(with viewModel: MenuCellViewModel) {
        _nameLabel.text = viewModel.nameText
        _ingredientsLabel.text = viewModel.ingredientsText
        _priceLabel.text = viewModel.priceText

        if let image = viewModel.image {
            // Image.
            _pizzaView.image = image
            _activityView.stopAnimating()
        } else if viewModel.shouldFetchImage {
            // Activity indicator.
            _activityView.startAnimating()
        }

        // Tap event.
        _tap.cmb.event()
            .sink(receiveValue: {
                viewModel.tap.send(())
            })
            .store(in: &_bag)
    }
}
