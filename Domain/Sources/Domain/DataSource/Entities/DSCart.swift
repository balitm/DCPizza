//
//  DSCart.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

extension DataSource {
    struct Cart: Codable {
        public let pizzas: [Pizza]
        public let drinks: [Drink.ID]
    }
}

extension DataSource.Cart: DomainConvertibleType {
    func asDomain(with ingredients: [DS.Ingredient], drinks: [DS.Drink]) -> Domain.Cart {
        let related = self.drinks.compactMap { id in
            drinks.first(where: { $0.id == id })
        }
        return Domain.Cart(
            pizzas: pizzas.map { $0.asDomain(with: ingredients, drinks: drinks) },
            drinks: related,
            basePrice: 0.0)
    }
}

extension Domain.Cart: DSRepresentable {
    func asDataSource() -> DS.Cart {
        DS.Cart(pizzas: pizzas.map { $0.asDataSource() },
                drinks: drinks.map(\.id))
    }
}
