//
//  CartItem.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/20/20.
//

import Foundation

public struct CartItem {
    public let name: String
    public let price: Double
    public let id: Int

    public init(name: String, price: Double, id: Int) {
        self.name = name
        self.price = price
        self.id = id
    }
}
