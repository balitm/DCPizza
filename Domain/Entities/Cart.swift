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
    public private(set) var drinks: [Drink]
    public internal(set) var basePrice: Double

    public mutating func add(pizza: Pizza) {
        pizzas.append(pizza)
    }

    public mutating func add(drink: Drink) {
        drinks.append(drink)
    }

    public mutating func remove(at index: Int) {
        let count = pizzas.count
        if index < count {
            pizzas.remove(at: index)
        } else {
            drinks.remove(at: index - count)
        }
    }

    public mutating func empty() {
        drinks = []
        pizzas = []
    }

    public func totalPrice() -> Double {
        let pizzaPrice = pizzas.reduce(0.0) {
            return $0 + $1.ingredients.reduce(basePrice) {
                return $0 + $1.price
            }
        }
        let drinkPrice = drinks.reduce(0.0) {
            $0 + $1.price
        }
        return pizzaPrice + drinkPrice
    }
}
