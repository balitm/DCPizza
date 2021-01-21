//
//  Drinks+Injection.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 7/10/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Resolver
import Domain
import Combine

extension Resolver {
    static func registerDrinks() {
        register {
            resolve(UseCaseProvider.self).makeDrinksService()
        }
        register {
            DrinksTableViewModel()
        }
    }
}
