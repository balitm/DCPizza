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

    init(pizza: UI.Pizza, basePrice: Double) {
        name = pizza.pizza.name
        priceText = "$\(pizza.pizza.price(from: basePrice))"
        id = pizza.id
    }

    init(drink: UI.Drink) {
        name = drink.drink.name
        priceText = "$\(drink.drink.price)"
        id = drink.id
    }
}
