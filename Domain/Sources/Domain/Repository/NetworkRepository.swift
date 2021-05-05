//
//  NetworkRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Combine
import class AlamofireImage.Image

protocol NetworkProtocol {
    func getPizzas() -> AnyPublisher<DS.Pizzas, API.ErrorType>
    func getIngredients() -> AnyPublisher<[DS.Ingredient], API.ErrorType>
    func getDrinks() -> AnyPublisher<[DS.Drink], API.ErrorType>
    func getImage(url: URL) -> AnyPublisher<Image, API.ErrorType>
    func checkout(cart: DS.Cart) -> AnyPublisher<Void, API.ErrorType>
}

extension API {
    struct Network: NetworkProtocol {
        func getPizzas() -> AnyPublisher<DS.Pizzas, API.ErrorType> {
            API.getPizzas()
        }

        func getIngredients() -> AnyPublisher<[DS.Ingredient], API.ErrorType> {
            API.getIngredients()
        }

        func getDrinks() -> AnyPublisher<[DS.Drink], API.ErrorType> {
            API.getDrinks()
        }

        func getImage(url: URL) -> AnyPublisher<Image, API.ErrorType> {
            API.downloadImage(url: url)
        }

        func checkout(cart: DS.Cart) -> AnyPublisher<Void, API.ErrorType> {
            API.checkout(pizzas: cart.pizzas, drinks: cart.drinks)
        }
    }
}
