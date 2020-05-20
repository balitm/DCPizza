//
//  CartItemCellModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain

struct CartItemCellViewModel {
    let name: String
    let priceText: String

    init(item: CartItem) {
        name = item.name
        priceText = format(price: item.price)
    }
}

extension CartItemCellViewModel: Hashable {}
