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
import RxSwift
import RxRelay

struct MenuCellViewModel {
    let nameText: String
    let ingredientsText: String
    let priceText: String
    let imageUrl: URL?
    let tap = PublishRelay<Void>()

    init(basePrice: Double, pizza: Pizza) {
        nameText = pizza.name
        let price = basePrice + pizza.ingredients.reduce(0.0) {
            $0 + $1.price
        }
        priceText = "$\(price)"
        var iNames = ""
        var it = pizza.ingredients.makeIterator()
        if let first = it.next() {
            iNames = first.name
            while let ingredient = it.next() {
                iNames += ", " + ingredient.name
            }
            iNames += "."
        }
        ingredientsText = iNames
        imageUrl = pizza.imageUrl
    }
}
