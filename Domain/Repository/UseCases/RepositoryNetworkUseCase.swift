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

    func getInitData() -> Observable<InitData> {
        _repository.getInitData()
    }

    func getIngredients() -> Observable<[Ingredient]> {
        _repository.getIngredients()
    }

    func getDrinks() -> Observable<[Drink]> {
        _repository.getDrinks()
    }
}
