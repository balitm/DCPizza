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

    public var id: ID { drink_id(_cppObject) }
    public var name: String { String(cString: drink_name(_cppObject)) }
    public var price: Double { drink_price(_cppObject) }

    private let _cppObject: OpaquePointer

    init(
        id: ID,
        name: String,
        price: Double
    ) {
        _cppObject = drink_create(id, name, price)!
    }

    deinit {
        drink_destroy(_cppObject)
    }
}
