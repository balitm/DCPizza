//
//  RepositoryNetworkUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Combine

final class RepositoryNetworkUseCase: NetworkUseCase {
    let _repository: RepositoryNetworkProtocol

    init(container: DS.Container?) {
        _repository = NetworkRepository(container: container)
    }

    func getInitData() -> AnyPublisher<InitData, Error> {
        _repository.getInitData()
    }

    func getIngredients() -> AnyPublisher<[Ingredient], Error> {
        _repository.getIngredients()
    }

    func getDrinks() -> AnyPublisher<[Drink], Error> {
        _repository.getDrinks()
    }

    func checkout(cart: Cart) -> AnyPublisher<Void, Error> {
        _repository.checkout(cart: cart.asDataSource())
    }
}
