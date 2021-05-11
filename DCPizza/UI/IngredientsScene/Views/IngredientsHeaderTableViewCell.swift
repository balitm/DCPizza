//
//  IngredientsHeaderTableViewCell.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/19/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Stevia

final class IngredientsHeaderTableViewCell: TableViewCellBase {
    private let _pizzaView = UIImageView()

    override func layoutSubviews() {
        separatorInset = UIEdgeInsets(top: 0, left: bounds.width / 2, bottom: 0, right: bounds.width / 2)
        super.layoutSubviews()
    }

    override func setupViews() {
        let bgView = UIImageView(image: UIImage(imageLiteralResourceName: "bg_wood"))
        let label = UILabel()

        _pizzaView.style { v in
            v.contentMode = .scaleAspectFit
        }

        contentView.subviews {
            bgView
            _pizzaView
            label
        }

        label.style { l in
            l.text = "Ingredients"
            l.font = UIFont.boldSystemFont(ofSize: 24)
            l.textColor = UIColor(.text)
        }

        // Layouts.
        bgView.fillHorizontally().height(300)
        bgView.Top == contentView.Top

        _pizzaView.Top == bgView.Top
        _pizzaView.Bottom == bgView.Bottom
        _pizzaView.Leading == bgView.Leading
        _pizzaView.Trailing == bgView.Trailing

        label.bottom(12).fillHorizontally(padding: 12)
        label.Top == _pizzaView.Bottom + 24
    }
}

extension IngredientsHeaderTableViewCell: CellViewModelProtocol {
    func config(with viewModel: IngredientsHeaderCellViewModel) {
        _pizzaView.image = viewModel.image
    }
}
