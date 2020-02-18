//
//  NetworkUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import RxSwift

public struct NetworkUseCase {
    public init() {}

    public func getIngredients() -> Observable<Void> {
        API.GetIngredients().rx.perform()
            .map({ _ in () })
    }

    public func getDrinks() -> Observable<Void> {
        API.GetDrinks().rx.perform()
            .map({ _ in () })
    }

    public func getPizzas() -> Observable<Void> {
        API.GetPizzas().rx.perform()
            .map({ _ in () })
    }
}
