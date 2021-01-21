//
//  Ingredients+Injection.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 7/3/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Resolver
import Domain
import RxSwift

extension Resolver {
    static func registerIngredients() {
        // Ingredients.
        register { _, args -> IngredientsUseCase in
            resolve(UseCaseProvider.self).makeIngredientsService(pizza: args())
        }
        register { _, args in
            IngredientsViewModel(service: resolve(args: args()))
        }
    }
}
