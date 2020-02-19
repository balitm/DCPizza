//
//  Navigator.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/19/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Domain

protocol Navigator {
    func showIngredients(of pizza: Pizza, image: UIImage?, ingredients: [Ingredient])
}

final class DefaultNavigator: Navigator {
    let storyboard: UIStoryboard
    private weak var _navigationController: UINavigationController!

    init(storyboard: UIStoryboard,
         navigationController: UINavigationController) {
        self.storyboard = storyboard
        _navigationController = navigationController
    }

    func showIngredients(of pizza: Pizza, image: UIImage?, ingredients: [Ingredient]) {
        let vm = IngredientsViewModel(pizza: pizza, image: image, ingredients: ingredients)
        let vc = IngredientsViewController.create(with: storyboard, viewModel: vm)
        _navigationController.pushViewController(vc, animated: true)
    }
}
