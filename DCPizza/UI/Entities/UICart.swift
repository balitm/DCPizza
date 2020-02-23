//
//  UICart.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/22/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain

enum UI {}

extension UI {
    struct Cart {
        fileprivate static var _additionNumber = 0

        private var _domainCart: Domain.Cart
        private var _ids: [Int]
        var basePrice: Double { _domainCart.basePrice }
        var pizzas: [Pizza] { _domainCart.pizzas }
        var drinks: [Drink] { _domainCart.drinks }
        var pizzaIds: [Int] { Array(_ids[0 ..< _domainCart.pizzas.endIndex]) }
        var drinkIds: [Int] { Array(_ids[_domainCart.pizzas.endIndex...]) }

        fileprivate init(
            domainCart: Domain.Cart,
            ids: [Int]
        ) {
            _domainCart = domainCart
            _ids = ids
        }

        mutating func add(pizza: Domain.Pizza) {
            _ids.insert(Cart._additionNumber, at: _domainCart.pizzas.count)
            _domainCart.add(pizza: pizza)
            Cart._additionNumber += 1
            assert(drinkIds.count == drinks.count)
            assert(pizzaIds.count == pizzas.count)
        }

        public mutating func add(drink: Domain.Drink) {
            _ids.append(Cart._additionNumber)
            _domainCart.add(drink: drink)
            Cart._additionNumber += 1
            assert(drinkIds.count == drinks.count)
            assert(pizzaIds.count == pizzas.count)
        }

        public mutating func remove(at index: Int) {
            _ids.remove(at: index)
            _domainCart.remove(at: index)
            assert(drinkIds.count == drinks.count)
            assert(pizzaIds.count == pizzas.count)
        }

        public mutating func empty() {
            _domainCart.empty()
            _ids = []
            Cart._additionNumber = 0
        }

        public func totalPrice() -> Double {
            return _domainCart.totalPrice()
        }
    }
}

extension Domain.Cart: UIConvertibleType {
    func asUI() -> UI.Cart {
        let pizzaIds = (0 ..< pizzas.endIndex).map { $0 }
        let offset = pizzaIds.count
        let drinkIds = (0 ..< drinks.endIndex).map { offset + $0 }

        UI.Cart._additionNumber = offset + drinkIds.count
        let uiCart = UI.Cart(domainCart: self, ids: pizzaIds + drinkIds)
        return uiCart
    }
}

extension UI.Cart: DomainRepresentable {
    func asDomain() -> Domain.Cart {
        return _domainCart
    }
}
