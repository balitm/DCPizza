//
//  Ingredient.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import CWrapper

public class Ingredient: CppConvertibleType {
    public typealias ID = Int64

    public var id: ID { ingredient_id(_cppObject) }
    public var name: String { String(cString: ingredient_name(_cppObject)) }
    public var price: Double { ingredient_price(_cppObject) }

    let _cppObject: OpaquePointer

    init(id: ID,
         name: String,
         price: Double)
    {
        _cppObject = ingredient_create(id, name, price)!
        // DLog("### 1. Creating ingredient: ", _baseAddress, "->", _cppObject)
    }

    required init(cppObject: OpaquePointer) {
        _cppObject = cppObject
        // DLog("### 2. Creating ingredient: ", _baseAddress, "->", _cppObject)
    }

    deinit {
        // DLog("### Destroying ingredient: ", _baseAddress, "->", _cppObject)
        ingredient_destroy(_cppObject)
    }
}
