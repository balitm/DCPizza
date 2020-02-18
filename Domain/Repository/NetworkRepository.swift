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
    func getPizzas() -> Observable<Pizzas>
}

struct NetworkRepository: RepositoryNetworkProtocol {
    init() {}

    func getIngredients() -> Observable<[Ingredient]> {
        API.GetIngredients().rx.perform()
    }

    func getDrinks() -> Observable<[Drink]> {
        API.GetDrinks().rx.perform()
    }

    func getPizzas() -> Observable<Pizzas> {
        API.GetPizzas().rx.perform()
    }
}
