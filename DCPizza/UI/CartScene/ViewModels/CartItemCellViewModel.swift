//
//  CartItemCellModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain

struct CartItemCellViewModel {
    let name: String
    let priceText: String

    init(pizza: Pizza, basePrice: Double) {
        name = pizza.name
        priceText = "$\(pizza.price(from: basePrice))"
    }
}
