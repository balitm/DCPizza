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
    let networkUseCase: NetworkUseCase
    let databaseUseCase: DatabaseUseCase

    init() {
        let provider = RepositoryUseCaseProvider()
        networkUseCase = provider.makeNetworkUseCase()
        databaseUseCase = provider.makeDatabaseUseCase()
    }

    func makeMenuTableViewModel() -> MenuTableViewModel {
        MenuTableViewModel(networkUseCase: networkUseCase,
                           databaseUseCase: databaseUseCase)
    }

    func makeNavigator(by viewController: UIViewController) -> Navigator {
        DefaultNavigator(storyboard: viewController.storyboard!,
                         navigationController: viewController.navigationController!,
                         dependencyContainer: self)
    }

    func makeCartViewModel(cart: Cart, drinks: [Drink]) -> CartViewModel {
        let dependencyContainer = CartDependencyContainer(appDependencyContainer: self)
        return dependencyContainer.makeCartViewModel(cart: cart, drinks: drinks)
    }
}
