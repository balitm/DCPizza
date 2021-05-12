//
//  TableViewCellBase.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 05/11/21.
//  Copyright © 2021. kil-dev. All rights reserved.
//

import UIKit

class TableViewCellBase: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Hook function to override to set up and layout views.
    func setupViews() {}
}
