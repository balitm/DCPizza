//
//  AppDependencyContainer.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/28/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import SwiftUI
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

    func makeMenuView() -> some View {
        func makeMenuListViewModel() -> MenuListViewModel {
            MenuListViewModel(service: menuService)
        }

        let mv = makeMenuListViewModel()
        return MenuListView(ingredientsFactory: self)
            .environmentObject(mv)
    }

    func makeCartViewModel() -> CartViewModel {
        CartViewModel(service: provider.makeCartService())
    }

    func makeDrinksTableViewModel() -> DrinksTableViewModel {
        DrinksTableViewModel(service: drinksService)
    }

    // Ingredients.

    func makeIngredientsView(pizza: AnyPublisher<Pizza, Never>) -> some View {
        let dependencyContainer = makeIngredientsDependencyContainer(pizza: pizza)
        return dependencyContainer.makeIngredientsView()
    }

    public func makeIngredientsDependencyContainer(pizza: AnyPublisher<Pizza, Never>) -> IngredientsDependencyContainer {
        IngredientsDependencyContainer(appDependencyContainer: self, pizza: pizza)
    }

    func makeSaveService() -> SaveUseCase {
        provider.makeSaveService()
    }
}
