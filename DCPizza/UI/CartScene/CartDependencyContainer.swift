//
//  CartDependencyContainer.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/28/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain

class CartDependencyContainer {
    let networkUseCase: NetworkUseCase

    public init(appDependencyContainer: AppDependencyContainer) {
        networkUseCase = appDependencyContainer.networkUseCase
    }

    func makeCartViewModel(cart: Cart, drinks: [Drink]) -> CartViewModel {
        CartViewModel(networkUseCase: networkUseCase, cart: cart, drinks: drinks)
    }
}
