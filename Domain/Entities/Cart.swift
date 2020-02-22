//
//  Cart.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

public struct Cart {
    public let pizzas: [Pizza]
    public let drinks: [Drink]
    public let basePrice: Double

    public init(
        pizzas: [Pizza],
        drinks: [Drink],
        basePrice: Double
    ) {
        self.pizzas = pizzas
        self.drinks = drinks
        self.basePrice = basePrice
    }

}
