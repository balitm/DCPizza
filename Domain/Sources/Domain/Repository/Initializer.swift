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

    @Published var component: ComponentsResult = .failure(API.ErrorType.disabled)
    let cartHandler: CartHandler

    private var _bag = Set<AnyCancellable>()

    deinit {
        DLog("Initializer deinited.")
    }

    init(container: DS.Container?, network: NetworkProtocol) {
        self.container = container
        self.network = network
        cartHandler = CartHandler(container: container)

        _bag = [
            // Get components.
            Publishers.Zip3(network.getPizzas(),
                            network.getIngredients(),
                            network.getDrinks())
                .map { (tuple: (pizzas: DS.Pizzas, ingredients: [DS.Ingredient], drinks: [DS.Drink])) -> ComponentsResult in
                    let ingredients = tuple.ingredients
                        .sorted { $0.name < $1.name }
                        .map { $0.asDomain() }
                    let drinks = tuple.drinks.map { $0.asDomain() }
                    let components = Components(pizzas: tuple.pizzas.asDomain(with: ingredients, drinks: drinks),
                                                ingredients: ingredients,
                                                drinks: drinks
                    )
                    return .success(components)
                }
                .catch {
                    Just(ComponentsResult.failure($0))
                }
                .assign(to: \.component, on: self),
        ]

        // Init card.
        $component
            .compactMap { try? $0.get() }
            .first()
            .receive(on: DS.dbQueue)
            .setFailureType(to: Error.self)
            .map { [weak container] c -> CartAction in
                // DLog("###### init cart. #########")
                let dsCart = container?.values(DS.Cart.self).first ?? DS.Cart(pizzas: [], drinks: [])
                let cart = dsCart.asDomain(with: c.ingredients, drinks: c.drinks)
                cart.basePrice = c.pizzas.basePrice
                return CartAction.start(with: cart)
            }
            .catch { _ in Empty<CartAction, Never>() }
            .subscribe(cartHandler.input)
    }
}
