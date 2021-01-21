//
//  MenuUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/14/20.
//

import Foundation
import RxSwift

public typealias PizzasResult = Result<Pizzas, API.ErrorType>

public protocol MenuUseCase {
    func pizzas() -> Observable<PizzasResult>
    func addToCart(pizza: Pizza) -> Completable
}
