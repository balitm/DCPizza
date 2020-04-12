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

    init(container: DS.Container?) {
        _repository = NetworkRepository(container: container)
    }

    func getInitData() -> Observable<InitData> {
        _repository.getInitData()
    }

    func getIngredients() -> Observable<[Ingredient]> {
        _repository.getIngredients()
    }

    func getDrinks() -> Observable<[Drink]> {
        _repository.getDrinks()
    }

    func checkout(cart: Cart) -> Observable<Void> {
        _repository.checkout(cart: cart.asDataSource())
    }
}
