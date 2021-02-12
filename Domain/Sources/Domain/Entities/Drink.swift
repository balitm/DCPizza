//
//  Drink.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
// @_exported import CWrapper

public struct Drink: Codable {
    public typealias ID = Int64

    public let id: ID
    public let name: String
    public let price: Double

    init(
        id: ID,
        name: String,
        price: Double
    ) {
        self.id = id
        self.name = name
        self.price = price
    }
}
