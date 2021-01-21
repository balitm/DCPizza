//
//  Pizzas.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

public struct Pizzas {
    public let pizzas: [Pizza]
    public let basePrice: Double

    public static let empty = Pizzas(pizzas: [], basePrice: 0)
}
