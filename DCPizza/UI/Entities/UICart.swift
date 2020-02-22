//
//  UICart.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/22/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain

extension UI {
    struct Cart {
        fileprivate static var _additionNumber = 0

        public private(set) var pizzas: [UI.Pizza]
        public private(set) var drinks: [UI.Drink]
        public private(set) var basePrice: Double

        public mutating func add(pizza: Domain.Pizza) {
            pizzas.append(UI.Pizza(pizza: pizza, id: Cart._additionNumber))
            Cart._additionNumber += 1
        }

        public mutating func add(drink: Domain.Drink) {
            drinks.append(UI.Drink(drink: drink, id: Cart._additionNumber))
            Cart._additionNumber += 1
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
                $0 + $1.pizza.ingredients.reduce(basePrice) {
                    $0 + $1.price
                }
            }
            let drinkPrice = drinks.reduce(0.0) {
                $0 + $1.drink.price
            }
            return pizzaPrice + drinkPrice
        }
    }
}

extension Domain.Cart: UIConvertibleType {
    func asUI() -> UI.Cart {
        var id = 0

        let uiPizzas = pizzas.map { pizza -> UI.Pizza in
            let uiPizza = UI.Pizza(pizza: pizza, id: id)
            id += 1
            return uiPizza
        }

        let uiDrinks = drinks.map { drink -> UI.Drink in
            let uiDrink = UI.Drink(drink: drink, id: id)
            id += 1
            return uiDrink
        }

        UI.Cart._additionNumber = id
        let uiCart = UI.Cart(pizzas: uiPizzas, drinks: uiDrinks, basePrice: basePrice)
        return uiCart
    }
}

extension UI.Cart: DomainRepresentable {
    func asDomain() -> Domain.Cart {
        let dPizzas = pizzas.map { $0.pizza }
        let dDrinks = drinks.map { $0.drink }
        let dCart = Domain.Cart(pizzas: dPizzas, drinks: dDrinks, basePrice: basePrice)
        return dCart
    }
}
