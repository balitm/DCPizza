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
    func getIngredients() -> Observable<Void>
    func getDrinks() -> Observable<Void>
    func getPizzas() -> Observable<Void>
}

struct NetworkRepository: RepositoryNetworkProtocol {
    init() {}

    func getIngredients() -> Observable<Void> {
        API.GetIngredients().rx.perform()
            .map({ _ in () })
    }

    func getDrinks() -> Observable<Void> {
        API.GetDrinks().rx.perform()
            .map({ _ in () })
    }

    func getPizzas() -> Observable<Void> {
        API.GetPizzas().rx.perform()
            .map({ _ in () })
    }
}
