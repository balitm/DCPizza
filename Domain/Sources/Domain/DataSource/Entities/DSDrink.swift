//
//  DSDrink.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

extension DataSource {
    struct Drink: Codable {
        public let id: ID
        public let name: String
        public let price: Double
    }
}

extension DataSource.Drink: DomainConvertibleType {
    typealias ID = Domain.Drink.ID

    func asDomain(with ingredients: [Ingredient], drinks: [Drink]) -> Domain.Drink {
        drinks.first { $0.id == id } ?? Domain.Drink(id: id, name: name, price: price)
    }
}

extension Domain.Drink: DSRepresentable {
    func asDataSource() -> DataSource.Drink {
        DataSource.Drink(id: id, name: name, price: price)
    }
}
