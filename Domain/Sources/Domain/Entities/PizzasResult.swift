//
//  PizzasResult.swift
//  Domain
//
//  Created by Balázs Kilvády on 05/14/21.
//

import Foundation

public struct PizzasResult {
    public let pizzas: Pizzas
    public let error: API.ErrorType?

    static let empty = PizzasResult(pizzas: Pizzas.empty, error: nil)

    init(pizzas: Pizzas,
         error: API.ErrorType? = nil) {
        self.pizzas = pizzas
        self.error = error
    }
}
