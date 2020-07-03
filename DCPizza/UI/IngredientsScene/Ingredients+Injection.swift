//
//  Ingredients+Injection.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 7/3/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

import Resolver
import Domain
import Combine

extension Resolver {
    static func registerInjectionServices() {
        // Ingredients.
        register { (_, arg) -> IngredientsUseCase in
            let pizza = _pizza(arg)
            return resolve(UseCaseProvider.self).makeIngredientsService(pizza: pizza)
        }
        register { (_, arg) -> IngredientsViewModel in
            IngredientsViewModel(service: resolve(args: arg))
        }
        register { (_, arg) -> IngredientsListView in
            IngredientsListView(viewModel: resolve(args: arg))
        }
    }
}

private func _pizza(_ arg: Any?) -> AnyPublisher<Pizza, Never> {
    (arg as? AnyPublisher<Pizza, Never> ?? Empty<Pizza, Never>().eraseToAnyPublisher())
}
