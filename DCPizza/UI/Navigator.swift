//
//  Navigator.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/19/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Domain
import RxSwift
import Resolver

protocol Navigator {
    var storyboard: UIStoryboard { get }

    func showIngredients(of pizza: Observable<Pizza>)
    func showCart()
    func showDrinks()
    func showAdded()
    func showSuccess()
}

final class DefaultNavigator: Navigator, Resolving {
    let storyboard: UIStoryboard
    private weak var _navigationController: UINavigationController!

    init(storyboard: UIStoryboard,
         navigationController: UINavigationController) {
        self.storyboard = storyboard
        _navigationController = navigationController
    }

    func showIngredients(of pizza: Observable<Pizza>) {
        let vm = resolver.resolve(IngredientsViewModel.self, args: pizza)
        let vc = IngredientsViewController.create(with: self, viewModel: vm)
        _navigationController.pushViewController(vc, animated: true)
    }

    func showCart() {
        let vc = CartViewController.create(with: self)
        _navigationController.pushViewController(vc, animated: true)
    }

    func showDrinks() {
        let vc = DrinksTableViewController.create(with: self)
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
