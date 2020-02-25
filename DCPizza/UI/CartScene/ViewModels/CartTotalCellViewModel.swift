//
//  CartTotalCellViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

struct CartTotalCellViewModel {
    let price: Double
    var priceText: String

    init(price: Double) {
        self.price = price
        priceText = format(price: price)
    }
}
