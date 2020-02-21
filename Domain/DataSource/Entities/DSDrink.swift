//
//  DSDrink.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

extension DataSource {
    public struct Drink: Codable {
        public typealias ID = Int64

        public let id: ID
        public let name: String
        public let price: Double
    }
}

extension DataSource.Drink: DomainConvertibleType {
    func asDomain(with ingredients: [DS.Ingredient], drinks: [DS.Drink]) -> Domain.Drink {
        drinks.first { $0.id == id } ?? Domain.Drink(id: -1, name: "", price: 0)
    }
}
