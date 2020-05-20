//
//  Initializer.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/12/20.
//

import Foundation
import Combine

final class Initializer {
    struct Components {
        let pizzas: Pizzas
        let ingredients: [Ingredient]
        let drinks: [Drink]

        static let empty = Components(pizzas: Pizzas(pizzas: [], basePrice: 0), ingredients: [], drinks: [])
    }

    typealias ComponentsResult = Result<Components, API.ErrorType>

    let container: DS.Container?
    let network: NetworkProtocol

    @Published var cart = Cart.empty
    @Published var component: ComponentsResult = .failure(API.ErrorType.disabled)

    private var _bag = Set<AnyCancellable>()

    init(container: DS.Container?, network: NetworkProtocol) {
        self.container = container
        self.network = network

        // Get components.
        Publishers.Zip3(network.getPizzas(),
                        network.getIngredients(),
                        network.getDrinks())
            .map({ (tuple: (pizzas: DS.Pizzas, ingredients: [DS.Ingredient], drinks: [DS.Drink])) -> ComponentsResult in
                let ingredients = tuple.ingredients.sorted { $0.name < $1.name }

                let components = Components(pizzas: tuple.pizzas.asDomain(with: ingredients, drinks: tuple.drinks),
                                            ingredients: ingredients,
                                            drinks: tuple.drinks)
                return .success(components)
            })
            .catch({
                Just(ComponentsResult.failure($0))
            })
            .assign(to: \.component, on: self)
            .store(in: &_bag)

        // Init card.
        $component
            .map({ [weak container] comp -> Cart in
                guard case let ComponentsResult.success(c) = comp else { return Cart.empty }

                let dsCart = container?.values(DS.Cart.self).first ?? DS.Cart(pizzas: [], drinks: [])
                var cart = dsCart.asDomain(with: c.ingredients, drinks: c.drinks)
                cart.basePrice = c.pizzas.basePrice
                return cart
            })
            .assign(to: \.cart, on: self)
            .store(in: &_bag)
    }
}
