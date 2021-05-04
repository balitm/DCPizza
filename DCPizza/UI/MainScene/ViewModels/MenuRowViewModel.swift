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

final class MenuRowViewModel: ObservableObject {
    @Published var tap = -1

    let index: Int
    let nameText: String
    let ingredientsText: String
    let priceText: String
    let image: Image?
    let url: URL?
    var isLoading: Bool { image == nil && url != nil }

    init(index: Int, basePrice: Double, pizza: Pizza) {
        self.index = index
        nameText = pizza.name
        let price = pizza.price(from: basePrice)
        priceText = format(price: price)
        ingredientsText = pizza.ingredientNames()
        image = pizza.image.map { Image(uiImage: $0) }
        url = pizza.imageUrl
    }

    func addToCart() {
        tap = index
    }
}

extension MenuRowViewModel: Identifiable {
    var id: Int { index + (image != nil ? 0x10 : 0) }
}
