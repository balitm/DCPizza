//
//  DatabaseUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/23/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

public protocol DatabaseUseCase {
    func deleteCart()
    func save(cart: Cart)
}
