//
//  MenuUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/14/20.
//

import Foundation
import Combine

public protocol MenuUseCase {
    func pizzas() -> AnyPublisher<PizzasResult, Never>
    func addToCart(pizza: Pizza) -> AnyPublisher<Void, Error>
}
