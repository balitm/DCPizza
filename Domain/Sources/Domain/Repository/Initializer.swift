//
//  Initializer.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/12/20.
//

import Foundation
import class AlamofireImage.Image
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

        let subscriber = AnySubscriber<(image: Image?, index: Int), Never>(receiveSubscription: {
            $0.request(.unlimited)
            DLog("Recived subscription: ", type(of: $0))
        }, receiveValue: { [unowned self] value in
            self.$component
                .compactMap { try? $0.get() }
                .first()
                .map { component in
                    DLog("insert image to: ", value.index)
                    let pizza = component.pizzas.pizzas[value.index]
                    var pizzas = component.pizzas.pizzas
                    pizzas[value.index] = Pizza(copy: pizza, image: value.image)
                    let all = Pizzas(pizzas: pizzas, basePrice: component.pizzas.basePrice)
                    return ComponentsResult.success(
                        Components(pizzas: all, ingredients: component.ingredients, drinks: component.drinks)
                    )
                }
                .assign(to: \.component, on: self)
                .store(in: &self._bag)

            return .unlimited
        }, receiveCompletion: {
            DLog("Received completion: ", $0)
        })

        _bag = [
            // Get components.
            Publishers.Zip3(network.getPizzas(),
                            network.getIngredients(),
                            network.getDrinks())
                .map { (tuple: (pizzas: DS.Pizzas, ingredients: [DS.Ingredient], drinks: [DS.Drink])) -> ComponentsResult in
                    let ingredients = tuple.ingredients.sorted { $0.name < $1.name }

                    let components = Components(pizzas: tuple.pizzas.asDomain(with: ingredients, drinks: tuple.drinks),
                                                ingredients: ingredients,
                                                drinks: tuple.drinks)
                    return .success(components)
                }
                .catch {
                    Just(ComponentsResult.failure($0))
                }
                .assign(to: \.component, on: self),

            // Download pizza images.
            $component
                .compactMap { try? $0.get() }
                .first()
                .sink(receiveValue: { component in
                    component.pizzas.pizzas.enumerated().forEach { item in
                        guard let imageUrl = item.element.imageUrl else { return }
                        network.getImage(url: imageUrl).map { $0 as Image? }
                            .catch { error -> Just<Image?> in
                                DLog("Error during image receiving: ", error)
                                return Just<Image?>(nil)
                            }
//                            .handleEvents(receiveOutput: {
//                                DLog("Inserting ", $0 == nil ? "nil" : "not nil")
//                            })
                            .map { ($0, item.offset) }
                            .subscribe(subscriber)
                    }
                }),

            // Init card.
            $component
                .compactMap { try? $0.get() }
                .first()
                .map { [weak container] c -> Cart in
                    DLog("###### init card. #########")
                    let dsCart = container?.values(DS.Cart.self).first ?? DS.Cart(pizzas: [], drinks: [])
                    var cart = dsCart.asDomain(with: c.ingredients, drinks: c.drinks)
                    cart.basePrice = c.pizzas.basePrice
                    return cart
                }
                .assign(to: \.cart, on: self),
        ]
    }
}
