//
//  DSPizzas.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

extension DataSource {
    struct Pizzas: Codable {
        let pizzas: [Pizza]
        let basePrice: Double

        init() {
            pizzas = []
            basePrice = 0
        }

        init(pizzas: [Pizza], basePrice: Double) {
            self.pizzas = pizzas
            self.basePrice = basePrice
        }
    }
}

extension DataSource.Pizzas: DomainConvertibleType {
    func asDomain(with ingredients: [Ingredient], drinks: [Drink]) -> Domain.Pizzas {
        let dPizzas = pizzas.map { pizza -> Domain.Pizza in
            pizza.asDomain(with: ingredients, drinks: drinks)
        }
        return Domain.Pizzas(pizzas: dPizzas, basePrice: basePrice)
    }
}

extension Domain.Pizzas: DSRepresentable {
    func asDataSource() -> DataSource.Pizzas {
        DS.Pizzas(pizzas: pizzas.map { $0.asDataSource() }
                  , basePrice: basePrice)
    }
}
