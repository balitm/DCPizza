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
            GetPizzas().cmb.perform()
        }

        func getIngredients() -> AnyPublisher<[DS.Ingredient], API.ErrorType> {
            GetIngredients().cmb.perform()
        }

        func getDrinks() -> AnyPublisher<[DS.Drink], API.ErrorType> {
            GetDrinks().cmb.perform()
        }

        func getImage(url: URL) -> AnyPublisher<Image, API.ErrorType> {
            let downloader = API.ImageDownloader(path: url.absoluteString)
            return downloader.cmb.perform()
        }

        func checkout(cart: DS.Cart) -> AnyPublisher<Void, API.ErrorType> {
            Checkout(pizzas: cart.pizzas, drinks: cart.drinks).cmb.perform()
                .map({ _ in () })
                .eraseToAnyPublisher()
        }
    }
}
