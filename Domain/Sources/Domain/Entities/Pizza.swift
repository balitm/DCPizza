//
//  Pizza.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Combine
import class AlamofireImage.Image

public struct Pizza {
    public let name: String
    public let ingredients: [Ingredient]
    public let imageUrl: URL?
    public let image: Image?

    public init(copy other: Pizza, with ingredients: [Ingredient]? = nil, image: Image? = nil) {
        name = other.name
        imageUrl = other.imageUrl
        self.ingredients = ingredients ?? other.ingredients
        self.image = image ?? other.image
    }

    public init() {
        name = "Custom"
        imageUrl = nil
        ingredients = []
        image = nil
    }

    init(
        name: String,
        ingredients: [Ingredient],
        imageUrl: URL?
    ) {
        self.name = name
        self.ingredients = ingredients
        self.imageUrl = imageUrl
        image = nil
    }

    public func price(from basePrice: Double) -> Double {
        let price = ingredients.reduce(basePrice) {
            $0 + $1.price
        }
        return price
    }

    public func ingredientNames() -> String {
        var iNames = ""
        var it = ingredients.makeIterator()
        if let first = it.next() {
            iNames = first.name
            while let ingredient = it.next() {
                iNames += ", " + ingredient.name
            }
            iNames += "."
        }
        return iNames
    }
}
