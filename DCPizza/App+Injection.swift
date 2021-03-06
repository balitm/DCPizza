//
//  App+Injection.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 6/29/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Resolver
import Domain

extension Resolver: ResolverRegistering {
    static let mock = Resolver(parent: main)

    public static func registerAllServices() {
        // Provider.
        register { RepositoryUseCaseProvider() as UseCaseProvider }
            .scope(.application)

        // Save service.
        register { resolve(UseCaseProvider.self).makeSaveService() }
            .scope(.application)

        // App view model.
        register { DCPizzaViewModel() }

        registerMainServices()
        registerIngredients()
        registerCarts()
        registerDrinks()
    }

    /// switch use case / service provider to the networkless mock.
    static func switchToNetworkless() {
        mock.register { NetworklessUseCaseProvider() as UseCaseProvider }
        root = mock
    }
}
