//
//  TestNetUseCase.swift
//
//
//  Created by Balázs Kilvády on 4/24/20.
//

import Foundation
import Combine
import class AlamofireImage.Image

struct TestNetUseCase: NetworkProtocol {
    private func _publish<T: Decodable>(_ data: T) -> AnyPublisher<T, API.ErrorType> {
        Result.Publisher(data).eraseToAnyPublisher()
    }

    func getIngredients() -> AnyPublisher<[DS.Ingredient], API.ErrorType> {
        _publish(PizzaData.dsIngredients)
    }

    func getDrinks() -> AnyPublisher<[DS.Drink], API.ErrorType> {
        _publish(PizzaData.dsDrinks)
    }

    func getPizzas() -> AnyPublisher<DS.Pizzas, API.ErrorType> {
        _publish(PizzaData.dsPizzas)
    }

    func getImage(url: URL) -> AnyPublisher<Image, API.ErrorType> {
        Empty<Image, API.ErrorType>().eraseToAnyPublisher()
    }

    func checkout(cart: DS.Cart) -> AnyPublisher<Void, API.ErrorType> {
        Result.Publisher(()).eraseToAnyPublisher()
    }
}
