//
//  Navigator.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/19/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Domain
import Combine

protocol Navigator {
    func showIngredients(of pizza: AnyPublisher<Pizza, Never>)
    func showCart()
    func showDrinks()
    func showAdded()
    func showSuccess()
}

final class DefaultNavigator: Navigator {
    private weak var _dependencyContainer: AppDependencyContainer!
    private weak var _navigationController: UINavigationController!

    init(navigationController: UINavigationController,
         dependencyContainer: AppDependencyContainer) {
        _navigationController = navigationController
        _dependencyContainer = dependencyContainer
    }

    func showIngredients(of pizza: AnyPublisher<Pizza, Never>) {
        let vm = _dependencyContainer.makeIngredientsViewModel(pizza: pizza)
        let vc = IngredientsViewController(navigator: self, viewModel: vm)
        _navigationController.pushViewController(vc, animated: true)
    }

    func showCart() {
        let vm = _dependencyContainer.makeCartViewModel()
        let vc = CartViewController(navigator: self, viewModel: vm)
        _navigationController.pushViewController(vc, animated: true)
    }

    func showDrinks() {
        let vm = _dependencyContainer.makeDrinksTableViewModel()
        let vc = DrinksTableViewController(navigator: self, viewModel: vm)
        _navigationController.pushViewController(vc, animated: true)
    }

    func showSuccess() {
        let vc = SuccessViewController()
        _navigationController.present(vc, animated: true)
    }

    func showAdded() {
        let vc = AddedViewController()
        _navigationController.present(vc, animated: true)
    }
}
