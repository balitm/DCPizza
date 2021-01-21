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
    let image: UIImage?
    let url: URL?
    let tap = PublishRelay<Void>()

    init(basePrice: Double, pizza: Pizza) {
        nameText = pizza.name
        let price = pizza.price(from: basePrice)
        priceText = format(price: price)
        ingredientsText = pizza.ingredientNames()
        image = pizza.image
        url = pizza.imageUrl
    }
}
