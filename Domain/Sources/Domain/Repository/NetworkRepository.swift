//
//  NetworkRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Combine

protocol RepositoryNetworkProtocol {
    func getInitData() -> AnyPublisher<InitData, Error>
    func getIngredients() -> AnyPublisher<[Ingredient], Error>
    func getDrinks() -> AnyPublisher<[Drink], Error>
    func checkout(cart: DS.Cart) -> AnyPublisher<Void, Error>
}

struct NetworkRepository: RepositoryNetworkProtocol, DatabaseContainerProtocol {
    let container: DS.Container?

    init(container: DS.Container?) {
        self.container = container
    }

    func getInitData() -> AnyPublisher<InitData, Error> {
        let netData = Publishers.Zip3(API.GetPizzas().cmb.perform(),
                                      API.GetIngredients().cmb.perform(),
                                      API.GetDrinks().cmb.perform())
            .map({ [weak container] (tuple: (pizzas: DS.Pizzas, ingredients: [DS.Ingredient], drinks: [DS.Drink])) -> InitData in
                let ingredients = tuple.ingredients.sorted { $0.name < $1.name }
                let dsCart = container?.values(DS.Cart.self).first ?? DS.Cart(pizzas: [], drinks: [])
                var cart = dsCart.asDomain(with: ingredients, drinks: tuple.drinks)
                cart.basePrice = tuple.pizzas.basePrice

                return InitData(pizzas: tuple.pizzas.asDomain(with: ingredients, drinks: tuple.drinks),
                                ingredients: ingredients,
                                drinks: tuple.drinks,
                                cart: cart)
            })
        return netData.eraseToAnyPublisher()
    }

    func getIngredients() -> AnyPublisher<[Ingredient], Error> {
        API.GetIngredients().cmb.perform()
    }

    func getDrinks() -> AnyPublisher<[Drink], Error> {
        API.GetDrinks().cmb.perform()
    }

    func checkout(cart: DS.Cart) -> AnyPublisher<Void, Error> {
        API.Checkout(pizzas: cart.pizzas, drinks: cart.drinks).cmb.perform()
            .handleEvents(receiveOutput: {
                self.execute {
                    try $0.write {
                        $0.delete(DS.Cart.self)
                        $0.delete(DS.Pizza.self)
                    }
                }
            })
            .eraseToAnyPublisher()
    }
}
