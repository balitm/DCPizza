//
//  Drink.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import CWrapper

public class Drink {
    public typealias ID = Int64

    public let id: ID
    public let name: String
    public let price: Double

    private let _cppObject: OpaquePointer

    init(
        id: ID,
        name: String,
        price: Double
    ) {
        self.id = id
        self.name = name
        self.price = price
        _cppObject = drink_create(1, "soda", 2)!
    }

    deinit {
        drink_destroy(_cppObject)
    }
}
