//
//  Ingredient.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

public struct Ingredient: Codable {
    public typealias ID = Int64

    public let id: ID
    public let name: String
    public let price: Double
}

