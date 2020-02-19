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
    func getIngredients() -> Observable<[Ingredient]>
    func getDrinks() -> Observable<[Drink]>
    func getPizzas() -> Observable<(pizzas: Pizzas, ingredients: [Ingredient])>
}

struct NetworkRepository: RepositoryNetworkProtocol {
    init() {}

    func getIngredients() -> Observable<[Ingredient]> {
        API.GetIngredients().rx.perform()
    }

    func getDrinks() -> Observable<[Drink]> {
        API.GetDrinks().rx.perform()
    }

    func getPizzas() -> Observable<(pizzas: Pizzas, ingredients: [Ingredient])> {
        return Observable.zip(API.GetPizzas().rx.perform(), API.GetIngredients().rx.perform()) { (pizzas: $0, ingredients: $1) }
            .map({ pair -> (pizzas: Pizzas, ingredients: [Ingredient]) in
                (pair.pizzas.asDomain(with: pair.ingredients), pair.ingredients)
            })
    }
}
