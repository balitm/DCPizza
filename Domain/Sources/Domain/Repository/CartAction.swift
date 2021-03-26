//
//  CartAction.swift
//  Domain
//
//  Created by Balázs Kilvády on 03/25/21.
//

import Foundation
import Combine

enum CartAction {
    case start(with: Cart)
    case pizza(pizza: Pizza)
    case drink(drink: Drink)
    case remove(index: Int)
    case empty
    case save
}

final class CartHandler {
    typealias CartResult = (cart: Cart, error: Error?)

    let cart: AnyPublisher<CartResult, Never>
    let input: AnySubscriber<CartAction, Never>

    init(container: DS.Container?) {
        let actionInput = PassthroughSubject<CartAction, Never>()

        cart = actionInput
            .scan((Cart.empty, nil)) { currentCart, action -> CartResult in
                _perform(container, currentCart.cart, action)
            }
            .eraseToAnyPublisher()

        input = AnySubscriber(actionInput)
    }

    func trigger(action: CartAction) -> AnyPublisher<Void, Error> {
        let publisher = cart
            .tryMap { cartResult -> Void in
                if let error = cartResult.error {
                    throw error
                }
                return ()
            }

        Just(CartAction.save)
            .subscribe(input)

        return publisher.eraseToAnyPublisher()
    }
}

private func _perform(_ container: DS.Container?,
                      _ currentCart: Cart,
                      _ action: CartAction) -> CartHandler.CartResult
{
    var cart = currentCart
    var error: Error?

    switch action {
    case let .start(with):
        cart = with
    case let .pizza(pizza):
        cart.add(pizza: pizza)
    case let .drink(drink):
        cart.add(drink: drink)
    case let .remove(index):
        cart.remove(at: index)
    case .empty:
        cart.empty()
        error = _dbAction(container)
    case .save:
        error = _dbAction(container) {
            $0.add(cart.asDataSource())
        }
    }

    return error == nil ? (cart, nil) : (currentCart, error)
}

private func _dbAction(_ container: DS.Container?,
                       _ operation: (DS.WriteTransaction) -> Void = { _ in }) -> Error?
{
    do {
        try container?.write {
            $0.delete(DS.Pizza.self)
            $0.delete(DS.Cart.self)
            operation($0)
        }
        return nil
    } catch {
        return error
    }
}
