//
//  Cart+Injection.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 7/6/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Resolver
import Domain

extension Resolver {
    static func registerCarts() {
        register {
            resolve(UseCaseProvider.self).makeCartService()
        }
        register {
            CartViewModel()
        }
        register {
            CartListView()
        }
    }
}
