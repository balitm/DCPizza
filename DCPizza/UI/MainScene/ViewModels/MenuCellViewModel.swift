//
//  MenuCellViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain
import class UIKit.UIImage

struct MenuCellViewModel {
    let nameText: String
    let ingredientsText: String
    let priceText: String
    let imageUrl: URL?

    init(basePrice: Double, pizza: Pizza, ingredients: [Ingredient]) {
        nameText = pizza.name
        let related = pizza.ingredients.compactMap { id in
            ingredients.first(where: { $0.id == id })
        }
        let price = basePrice + related.reduce(0.0) {
            $0 + $1.price
        }
        priceText = "$\(price)"
        var iNames = ""
        var it = related.makeIterator()
        if let first = it.next() {
            iNames = first.name
            while let ingredient = it.next() {
                iNames += ", " + ingredient.name
            }
            iNames += "."
        }
        ingredientsText = iNames

        if let str = pizza.imageUrl {
            imageUrl = URL(string: str)
        } else {
            imageUrl = nil
        }
    }
}
