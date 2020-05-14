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

    func getInitData() -> AnyPublisher<InitData, API.ErrorType> {
        _repository.getInitData()
    }

    func getIngredients() -> AnyPublisher<[Ingredient], API.ErrorType> {
        _repository.getIngredients()
    }

    func getDrinks() -> AnyPublisher<[Drink], API.ErrorType> {
        _repository.getDrinks()
    }

    func checkout(cart: Cart) -> AnyPublisher<Void, API.ErrorType> {
        _repository.checkout(cart: cart.asDataSource())
    }
}
