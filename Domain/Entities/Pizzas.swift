//
//  Pizzas.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

public struct Pizzas: Codable {
    public let pizzas: [Pizza]
    public let basePrice: Double

    init() {
        pizzas = []
        basePrice = 0
    }
}
