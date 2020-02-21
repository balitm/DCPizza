//
//  Pizza.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import class UIKit.UIImage

public struct Pizza {
    public let name: String
    public let ingredients: [Ingredient]
    public let imageUrl: URL?

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
