//
//  Cart.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import CWrapper

private typealias _SetupFunction<R> = (UnsafeMutablePointer<OpaquePointer?>, Int,
                                       UnsafeMutablePointer<OpaquePointer?>, Int) -> R

final class Cart {
    static let empty = Cart()

    let _cppObject: OpaquePointer

    init(pizzas: [Pizza], drinks: [Drink], basePrice: Double) {
        _cppObject = _cppArrays(from: pizzas, secondArray: drinks) {
            cart_create($0, $1, $2, $3, basePrice)
        }
    }

    private init() {
        _cppObject = cart_create_empty()
    }

    // MARK: - Accessors

    var basePrice: Double {
        get { cart_base_price(_cppObject) }
        set { cart_set_base_price(_cppObject, newValue) }
    }

    var drinks: [Drink] {
        _objects(cart_drinks)
    }

    var pizzas: [Pizza] {
        _objects(cart_pizzas)
    }

    // MARK: - Functions

    func add(pizza: Pizza) {
        cart_add_pizza(_cppObject, pizza._cppObject)
    }

    func add(drink: Drink) {
        cart_add_drink(_cppObject, drink._cppObject)
    }

    func remove(at index: Int) {
        cart_remove(_cppObject, Int32(index))
    }

    func empty() {
        cart_empty(_cppObject)
    }

    var isEmpty: Bool {
        cart_is_empty(_cppObject)
    }

    func totalPrice() -> Double {
        cart_total_price(_cppObject)
    }

    func items() -> [CartItem] {
        var size = -1
        let carray = cart_items(_cppObject, &size)
        assert(size >= 0)

        // Get size in bytes.
        size *= MemoryLayout<UnsafeMutablePointer<CartItem>>.size

        // Create an array.
        let rawBufferPtr = UnsafeRawBufferPointer(start: UnsafeRawPointer(carray), count: size)
        let ptrBuffer = rawBufferPtr.bindMemory(to: UnsafeMutablePointer<CWrapper.CartItem>.self)
        let items = ptrBuffer.map { ptr -> CartItem in
            DLog("ccitem to move: ", ptr)
            let instance = Domain.CartItem(cppObject: ptr.move())
            DLog("ccitem moved to: ", instance._baseAddress, "->", instance._cppObject)
            return instance
        }
        ptrBuffer.deallocate()
        return items
    }

    private func _objects<T>(_ getter: (OpaquePointer?, UnsafeMutablePointer<Int>?) -> UnsafeMutablePointer<OpaquePointer?>?) -> [T] where T: CppConvertibleType, T.CppPointer == OpaquePointer {
        var size = -1
        let carray = getter(_cppObject, &size)
        assert(size >= 0)

        // Get size in bytes.
        size *= MemoryLayout<OpaquePointer>.size

        // Create an array.
        let rawBufferPtr = UnsafeRawBufferPointer(start: UnsafeRawPointer(carray), count: size)
        let ptrBuffer = rawBufferPtr.bindMemory(to: OpaquePointer.self)
        let ingredients = ptrBuffer.map {
            T(cppObject: $0)
        }
        ptrBuffer.deallocate()
        return ingredients
    }
}

private func _cppArrays<T0, T1, R>(from firstArray: [T0], secondArray: [T1],
                                   setup: _SetupFunction<R>) -> R where T0: CppConvertibleType, T1: CppConvertibleType, T0.CppPointer == OpaquePointer, T1.CppPointer == OpaquePointer
{
    firstArray
        .map { $0._cppObject as OpaquePointer? }
        .withUnsafeBufferPointer { first in
            secondArray
                .map { $0._cppObject as OpaquePointer? }
                .withUnsafeBufferPointer { second in
                    let firstPtr = UnsafeMutablePointer<OpaquePointer?>(mutating: first.baseAddress)!
                    let secondPtr = UnsafeMutablePointer<OpaquePointer?>(mutating: second.baseAddress)!
                    return setup(firstPtr, first.count, secondPtr, second.count)
                }
        }
}
