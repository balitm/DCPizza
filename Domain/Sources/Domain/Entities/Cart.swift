//
//  Cart.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

public struct Cart {
    public static var empty: Cart { Cart(pizzas: [], drinks: [], basePrice: 0) }

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

    public var isEmpty: Bool {
        pizzas.isEmpty && drinks.isEmpty
    }

    public func totalPrice() -> Double {
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
}

// extension Cart: CombineCompatible {}
//
// extension Combinable where Base == Cart {
//    enum Item {
//        case pizza(pizza: Pizza)
//        case drink(drink: Drink)
//    }
//
//    var addItem: AnySubscriber<Item, API.ErrorType> {
//        AnySubscriber<Item, API.ErrorType>(receiveSubscription: {
//            DLog("subscription: ", $0)
//        }, receiveValue: {
//            switch $0 {
//            case let .pizza(pizza):
//                DLog("add pizza: ", pizza.name)
//                base.add(pizza: pizza)
//            case let .drink(drink):
//                DLog("add drink: ", drink.name)
//                base.add(drink: drink)
//            }
//            return .unlimited
//        }, receiveCompletion: {
//            DLog("completion: ", $0)
//        })
//    }
// }
