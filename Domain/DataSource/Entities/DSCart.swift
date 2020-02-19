//
//  DSCart.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

extension DataSource {
    struct Cart: Codable {
        public let pizzas: [Pizza]
        public let drinks: [Drink.ID]
    }
}
