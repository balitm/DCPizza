//
//  AppDependencyContainer.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/28/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Domain

class AppDependencyContainer {
    let menuService: MenuUseCase
    let drinksService: DrinksUseCase
    let provider: UseCaseProvider

    init() {
        provider = RepositoryUseCaseProvider()
        menuService = provider.makeMenuUseCase()
        drinksService = provider.makeDrinsService()
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

    func makeIngredientsViewModel(pizza: Pizza) -> IngredientsViewModel {
        let dependencyContainer = IngredientsDependencyContainer(appDependencyContainer: self, pizza: pizza)
        return dependencyContainer.makeIngredientsViewModel()
    }

    func makeSaveService() -> SaveUseCase {
        provider.makeSaveService()
    }
}
