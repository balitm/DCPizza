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
    var storyboard: UIStoryboard { get }

    func showCart()
    func showDrinks()
    func showAdded()
    func showSuccess()
}

final class DefaultNavigator: Navigator {
    let storyboard: UIStoryboard
    private weak var _dependencyContainer: AppDependencyContainer!
    private weak var _navigationController: UINavigationController!

    init(storyboard: UIStoryboard,
         navigationController: UINavigationController,
         dependencyContainer: AppDependencyContainer) {
        self.storyboard = storyboard
        _navigationController = navigationController
        _dependencyContainer = dependencyContainer
    }

    func showCart() {
        let vm = _dependencyContainer.makeCartViewModel()
        let vc = CartViewController.create(with: self, viewModel: vm)
        _navigationController.pushViewController(vc, animated: true)
    }

    func showDrinks() {
        let vm = _dependencyContainer.makeDrinksTableViewModel()
        let vc = DrinksTableViewController.create(with: self, viewModel: vm)
        _navigationController.pushViewController(vc, animated: true)
    }

    func showSuccess() {
        let vc = SuccessViewController.create(with: storyboard)
        _navigationController.present(vc, animated: true)
    }

    func showAdded() {
        let vc = storyboard.load(type: AddedViewController.self)
        _navigationController.present(vc, animated: true)
    }
}
