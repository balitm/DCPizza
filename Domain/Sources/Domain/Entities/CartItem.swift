//
//  CartItem.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/20/20.
//

import Foundation
import CWrapper

public final class CartItem: CppConvertibleType {
    let _cppObject: CWrapper.CartItem

    public var name: String { String(cString: _cppObject.name) }
    public var price: Double { _cppObject.price }
    public var id: Int { Int(_cppObject.id) }

    public init(cppObject: CWrapper.CartItem) {
        _cppObject = cppObject
    }

    deinit {
        DLog("Deinit of ", _baseAddress, "->", _cppObject)
    }

    #if DEBUG
        public init(name: String, price: Double, id: Int) {
            _cppObject = cart_item_create(name, price, Int32(id))!.move()
        }
    #endif
}
