//
//  MenuCellViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain
import struct SwiftUI.Image
import Combine

struct MenuRowViewModel {
    let nameText: String
    let ingredientsText: String
    let priceText: String
    let image: Image?
    let url: URL?
    let tap = PassthroughSubject<Void, Never>()

    init(basePrice: Double, pizza: Pizza) {
        nameText = pizza.name
        let price = pizza.price(from: basePrice)
        priceText = format(price: price)
        ingredientsText = pizza.ingredientNames()
        image = pizza.image.map { Image(uiImage: $0) }
        url = pizza.imageUrl
    }
}

extension MenuRowViewModel: Identifiable {
    var id: String { nameText }
}
