//
//  Ingredients+Injection.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 7/3/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Resolver
import Domain
import Combine

extension Resolver {
    static func registerIngredients() {
        // Ingredients.
        register { _, args -> IngredientsUseCase in
            resolve(UseCaseProvider.self).makeIngredientsService(pizza: args())
        }
        register { _, args -> IngredientsViewModel in
            IngredientsViewModel(service: resolve(args: args()))
        }
        register { _, args -> IngredientsListView in
            IngredientsListView(viewModel: resolve(args: args()))
        }
    }
}

private func _pizza(_ arg: Any?) -> AnyPublisher<Pizza, Never> {
    (arg as? AnyPublisher<Pizza, Never> ?? Empty<Pizza, Never>().eraseToAnyPublisher())
}
