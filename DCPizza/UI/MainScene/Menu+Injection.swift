//
//  Menu+Injection.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 6/29/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Resolver
import Domain
import Combine

extension Resolver {
    static func registerMainServices() {
        // Main/menu.
        register {
            resolve(UseCaseProvider.self).makeMenuService()
        }
        register {
            MenuListViewModel(service: resolve())
        }
        register {
            MenuListView()
        }
    }
}
