//
//  CartItemCellModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain

struct CartItemRowViewModel {
    let name: String
    let priceText: String
    let index: Int

    init(item: CartItem, index: Int) {
        self.index = index
        name = item.name
        priceText = format(price: item.price)
    }
}
