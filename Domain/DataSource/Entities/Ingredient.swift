//
//  Ingredient.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

extension DataSource {
    struct Ingredient: Codable {
        typealias ID = Int64

        let id: ID
        let name: String
        let price: Double
    }
}
