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
    func asDomain(with ingredients: [DS.Ingredient]) -> Domain.Cart {
        Domain.Cart(pizzas: pizzas.map { $0.asDomain(with: ingredients) },
                    drinks: drinks)
    }
}

extension Domain.Cart: DSRepresentable {
    func asDataSource() -> DS.Cart {
        DS.Cart(pizzas: pizzas.map { $0.asDataSource() },
                drinks: drinks)
    }
}
