//
//  TestNetUseCase.swift
//
//
//  Created by Balázs Kilvády on 4/24/20.
//

import Foundation
import Combine

struct TestNetUseCase: NetworkProtocol {
    private func _publish<T: Decodable>(_ data: T) -> AnyPublisher<T, API.ErrorType> {
        Result.Publisher(data).eraseToAnyPublisher()
    }

    func getIngredients() -> AnyPublisher<[Ingredient], API.ErrorType> {
        _publish(PizzaData.ingredients)
    }

    func getDrinks() -> AnyPublisher<[DS.Drink], API.ErrorType> {
        _publish(PizzaData.drinks)
    }

    func getPizzas() -> AnyPublisher<DS.Pizzas, API.ErrorType> {
        _publish(PizzaData.dsPizzas)
    }

    func checkout(cart: DS.Cart) -> AnyPublisher<Void, API.ErrorType> {
        Result.Publisher(()).eraseToAnyPublisher()
    }
}
