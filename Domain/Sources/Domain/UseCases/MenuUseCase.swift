//
//  MenuUseCase.swift
//
//
//  Created by Balázs Kilvády on 5/14/20.
//

import Foundation
import Combine

public typealias PizzasResult = Result<Pizzas, API.ErrorType>

public protocol MenuUseCase {
    func pizzas() -> AnyPublisher<PizzasResult, Never>
    func add(pizza: Pizza) -> AnyPublisher<Void, Error>
    func saveCart() -> AnyPublisher<Void, Error>
}
