//
//  DSPizza.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

extension DataSource {
    struct Pizza: Codable {
        let name: String
        let ingredients: [Ingredient.ID]
        let imageUrl: String?
    }
}

extension DataSource.Pizza: DomainConvertibleType {
    func asDomain(with ingredients: [DS.Ingredient]) -> Domain.Pizza {
        let related = self.ingredients.compactMap { id in
            ingredients.first(where: { $0.id == id })
        }
        let imageURL: URL? = {
            guard let str = imageUrl else { return nil }
            return URL(string: str)
        }()
        return Domain.Pizza(name: name, ingredients: related, imageUrl: imageURL)
    }
}

extension Domain.Pizza: DSRepresentable {
    func asDataSource() -> DataSource.Pizza {
        return DS.Pizza(name: name,
                        ingredients: ingredients.map { $0.id },
                        imageUrl: imageUrl?.absoluteString)
    }
}
