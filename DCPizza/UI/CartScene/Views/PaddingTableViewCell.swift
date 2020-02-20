//
//  PaddingTableViewCell.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit

class PaddingTableViewCell: SeparableTableViewCell {
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
}

extension PaddingTableViewCell: CellViewModelProtocol {
    func config(with viewModel: PaddingCellViewModel) {
        heightConstraint.constant = viewModel.height
    }
}
