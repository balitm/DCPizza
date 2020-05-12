//
//  InitData.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

public struct InitData {
    public let pizzas: Pizzas
    public let ingredients: [Ingredient]
    public let drinks: [Drink]
    public let cart: Cart

    public static var empty: InitData {
        InitData(pizzas: Pizzas(pizzas: [], basePrice: 0),
                 ingredients: [],
                 drinks: [],
                 cart: Cart.empty)
    }
}
