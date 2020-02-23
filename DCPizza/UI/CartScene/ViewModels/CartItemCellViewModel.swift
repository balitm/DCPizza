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
    let id: Int

    init(pizza: Pizza, basePrice: Double, id: Int) {
        name = pizza.name
        priceText = "$\(pizza.price(from: basePrice))"
        self.id = id
    }

    init(drink: Drink, id: Int) {
        name = drink.name
        priceText = "$\(drink.price)"
        self.id = id
    }
}
