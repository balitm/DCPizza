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
    let _repository: NetworkRepository

    init() {
        _repository = NetworkRepository()
    }

    func getIngredients() -> Observable<Void> {
        _repository.getIngredients()
    }

    func getDrinks() -> Observable<Void> {
        _repository.getDrinks()
    }

    func getPizzas() -> Observable<Void> {
        _repository.getPizzas()
    }
}
