//
//  AppDependencyContainer.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/28/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Combine
import Domain

class AppDependencyContainer {
    let menuService: MenuUseCase
    let drinksService: DrinksUseCase
    let provider: UseCaseProvider

    init() {
        provider = RepositoryUseCaseProvider()
        menuService = provider.makeMenuService()
        drinksService = provider.makeDrinksService()
    }

    func makeMenuTableViewModel() -> MenuTableViewModel {
        MenuTableViewModel(service: menuService)
    }

    func makeNavigator(by viewController: UIViewController) -> Navigator {
        DefaultNavigator(storyboard: viewController.storyboard!,
                         navigationController: viewController.navigationController!,
                         dependencyContainer: self)
    }

    func makeCartViewModel() -> CartViewModel {
        CartViewModel(service: provider.makeCartService())
    }

    func makeDrinksTableViewModel() -> DrinksTableViewModel {
        DrinksTableViewModel(service: drinksService)
    }

    func makeIngredientsViewModel(pizza: AnyPublisher<Pizza, Never>) -> IngredientsViewModel {
        let dependencyContainer = IngredientsDependencyContainer(appDependencyContainer: self, pizza: pizza)
        return dependencyContainer.makeIngredientsViewModel()
    }

    func makeSaveService() -> SaveUseCase {
        provider.makeSaveService()
    }
}
