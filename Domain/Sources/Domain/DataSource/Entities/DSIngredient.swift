//
//  DSIngredient.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

extension DataSource {
    struct Ingredient: Codable {
        public let id: ID
        public let name: String
        public let price: Double
    }
}

extension DataSource.Ingredient: DomainConvertibleType {
    typealias ID = Domain.Ingredient.ID

    func asDomain(with ingredients: [Ingredient], drinks: [Drink]) -> Domain.Ingredient {
        ingredients.first { $0.id == id } ?? Domain.Ingredient(id: id, name: name, price: price)
    }
}

extension Domain.Ingredient: DSRepresentable {
    func asDataSource() -> DataSource.Ingredient {
        DataSource.Ingredient(id: id, name: name, price: price)
    }
}
