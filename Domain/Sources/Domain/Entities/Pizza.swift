//
//  Pizza.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Combine
import class AlamofireImage.Image
import CWrapper

public class Pizza: CppConvertibleType {
    public var name: String { String(cString: pizza_name(_cppObject)) }
    public var ingredients: [Ingredient] {
        var size = -1
        let carray = pizza_ingredients(_cppObject, &size)
        assert(size >= 0)

        // Get size in bytes.
        size *= MemoryLayout<OpaquePointer>.size

        // Create an array.
        let rawBufferPtr = UnsafeRawBufferPointer(start: UnsafeRawPointer(carray), count: size)
        let ptrBuffer = rawBufferPtr.bindMemory(to: OpaquePointer.self)
        let ingredients = ptrBuffer.map {
            Ingredient(cppObject: $0)
        }
        ptrBuffer.deallocate()
        return ingredients
    }

    public var imageUrl: URL? {
        guard let ptr = pizza_url_string(_cppObject) else { return nil }
        let urlString = String(cString: ptr)
        return URL(string: urlString)
    }

    public let image: Image?

    let _cppObject: OpaquePointer

    public init(copy other: Pizza, with ingredients: [Ingredient]? = nil, image: Image? = nil) {
        _cppObject = _cppArray(from: ingredients) {
            pizza_create_copy(other._cppObject, $0, $1)
        }
        self.image = image ?? other.image
    }

    public init() {
        _cppObject = _cppArray(from: [Ingredient]()) {
            pizza_create("Custom", $0, $1, "")
        }
        image = nil
    }

    init(
        name: String,
        ingredients: [Ingredient],
        imageUrl: URL?
    ) {
        _cppObject = _cppArray(from: ingredients) {
            pizza_create(name,
                         $0, $1,
                         imageUrl?.absoluteString)
        }
        image = nil
    }

    deinit {
        pizza_destroy(_cppObject)
    }

    public func price(from basePrice: Double) -> Double {
        pizza_price(_cppObject, basePrice)
    }

    public func ingredientNames() -> String {
        let ptr = pizza_ingredient_names(_cppObject)!
        let res = String(cString: ptr)
        ptr.deallocate()
        return res
    }
}

private func _cppArray<T, R>(from array: [T]?,
                             setup: (UnsafeMutablePointer<OpaquePointer?>?, Int) -> R) -> R where T: CppConvertibleType
{
    if let array = array {
        return array
            .map { $0._cppObject as OpaquePointer? }
            .withUnsafeBufferPointer {
                let ptr = UnsafeMutablePointer<OpaquePointer?>(mutating: $0.baseAddress)!
                return setup(ptr, array.count)
            }
    } else {
        return setup(nil, 0)
    }
}
