//
//  NetworkRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import RxSwift


protocol RepositoryNetworkProtocol {
    func getInitData() -> Observable<InitData>
    func getIngredients() -> Observable<[Ingredient]>
    func getDrinks() -> Observable<[Drink]>
    func checkout(cart: DS.Cart) -> Observable<Void>
}

struct NetworkRepository: RepositoryNetworkProtocol {
    init() {}

    func getInitData() -> Observable<InitData> {
        let netData = Observable.zip(API.GetPizzas().rx.perform(),
                                     API.GetIngredients().rx.perform(),
                                     API.GetDrinks().rx.perform(),
                                     resultSelector: { (pizzas: $0, ingredients: $1, drinks: $2) })
            .map({ tuple -> InitData in
                let ingredients = tuple.ingredients.sorted { $0.name < $1.name }
                return InitData(pizzas: tuple.pizzas.asDomain(with: ingredients, drinks: tuple.drinks),
                                ingredients: ingredients,
                                drinks: tuple.drinks,
                                cart: Domain.Cart(pizzas: [],
                                                  drinks: [],
                                                  basePrice: tuple.pizzas.basePrice))
            })
        return netData
    }

    func getIngredients() -> Observable<[Ingredient]> {
        API.GetIngredients().rx.perform()
    }

    func getDrinks() -> Observable<[Drink]> {
        API.GetDrinks().rx.perform()
    }

    func checkout(cart: DS.Cart) -> Observable<Void> {
        API.Checkout(pizzas: cart.pizzas, drinks: cart.drinks).rx.perform()
    }
}
