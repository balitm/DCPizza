//
//  RepositoryNetworkUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import RxSwift

final class RepositoryNetworkUseCase: NetworkUseCase {
    let _repository: RepositoryNetworkProtocol

    init() {
        _repository = NetworkRepository()
    }

    func getIngredients() -> Observable<[Ingredient]> {
        _repository.getIngredients()
    }

    func getDrinks() -> Observable<[Drink]> {
        _repository.getDrinks()
    }

    func getPizzas() -> Observable<(pizzas: Pizzas, ingredients: [Ingredient])> {
        _repository.getPizzas()
    }
}
