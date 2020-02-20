//
//  Cart.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

public struct Cart {
    public private(set) var pizzas: [Pizza]
    public private(set) var drinks: [Drink.ID]

    public mutating func add(pizza: Pizza) {
        pizzas.append(pizza)
    }

    public mutating func add(drink: Drink) {
        drinks.append(drink.id)
    }
}
