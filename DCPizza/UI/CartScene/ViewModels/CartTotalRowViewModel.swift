//
//  CartTotalCellViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

struct CartTotalRowViewModel {
    var priceText: String

    init(price: Double) {
        priceText = format(price: price)
    }
}
