//
//  Cart.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

extension DataSource {
    struct Cart: Codable {
        let pizzas: [Pizza]
        let drinks: [Drink.ID]
    }
}
