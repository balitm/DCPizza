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

protocol Navigator {
    var storyboard: UIStoryboard { get }

    func showIngredients(of pizza: Pizza,
                         image: UIImage?,
                         ingredients: [Ingredient],
                         cart: Cart) -> (Observable<Cart>, DisposeBag)
    func showAdded()
}

final class DefaultNavigator: Navigator {
    let storyboard: UIStoryboard
    private weak var _navigationController: UINavigationController!

    init(storyboard: UIStoryboard,
         navigationController: UINavigationController) {
        self.storyboard = storyboard
        _navigationController = navigationController
    }

    func showIngredients(of pizza: Pizza,
                         image: UIImage?,
                         ingredients: [Ingredient],
                         cart: Cart) -> (Observable<Cart>, DisposeBag) {
        let vm = IngredientsViewModel(pizza: pizza, image: image, ingredients: ingredients, cart: cart)
        let vc = IngredientsViewController.create(with: self, viewModel: vm)
        _navigationController.pushViewController(vc, animated: true)
        return (vm.cart, vc.bag)
    }

    func showAdded() {
        let vc = storyboard.load(type: AddedViewController.self)
        _navigationController.present(vc, animated: true)
    }
}
