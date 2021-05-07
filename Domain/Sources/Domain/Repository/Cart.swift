//
//  Cart.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

struct Cart {
    static let empty = Cart(pizzas: [], drinks: [], basePrice: 0)
    private static var _additionNumber = 0

    private(set) var pizzas: [Pizza]
    private(set) var drinks: [Drink]
    var basePrice: Double

    private var _ids: [Int]
    private var _pizzaIds: [Int] { Array(_ids[0 ..< pizzas.endIndex]) }
    private var _drinkIds: [Int] { Array(_ids[pizzas.endIndex...]) }

    init(pizzas: [Pizza], drinks: [Drink], basePrice: Double) {
        self.pizzas = pizzas
        self.drinks = drinks
        self.basePrice = basePrice
        Cart._additionNumber = pizzas.count + drinks.count
        _ids = (0 ..< Cart._additionNumber).map { $0 }
    }

    mutating func add(pizza: Pizza) {
        _ids.insert(Cart._additionNumber, at: pizzas.count)
        pizzas.append(pizza)
        Cart._additionNumber += 1
        assert(_drinkIds.count == drinks.count)
        assert(_pizzaIds.count == pizzas.count)
    }

    mutating func add(drink: Drink) {
        _ids.append(Cart._additionNumber)
        drinks.append(drink)
        Cart._additionNumber += 1
        assert(_drinkIds.count == drinks.count)
        assert(_pizzaIds.count == pizzas.count)
    }

    mutating func remove(at index: Int) {
        _ids.remove(at: index)
        let count = pizzas.count
        if index < count {
            pizzas.remove(at: index)
        } else {
            drinks.remove(at: index - count)
        }
        assert(_drinkIds.count == drinks.count)
        assert(_pizzaIds.count == pizzas.count)
    }

    mutating func empty() {
        drinks = []
        pizzas = []
        _ids = []
        Cart._additionNumber = 0
    }

    var isEmpty: Bool {
        pizzas.isEmpty && drinks.isEmpty
    }

    func totalPrice() -> Double {
        let pizzaPrice = pizzas.reduce(0.0) {
            $0 + $1.ingredients.reduce(basePrice) {
                $0 + $1.price
            }
        }
        let drinkPrice = drinks.reduce(0.0) {
            $0 + $1.price
        }
        return pizzaPrice + drinkPrice
    }

    func items() -> [CartItem] {
        var items = pizzas.enumerated().map { pizza in
            CartItem(name: pizza.element.name,
                     price: pizza.element.ingredients.reduce(basePrice) {
                         $0 + $1.price
                     },
                     id: _pizzaIds[pizza.offset])
        }
        items.append(contentsOf: drinks.enumerated().map {
            CartItem(name: $0.element.name, price: $0.element.price, id: _drinkIds[$0.offset])
        })

        return items
    }
}
