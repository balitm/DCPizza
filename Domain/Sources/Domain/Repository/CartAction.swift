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

    let cartResult: AnyPublisher<CartResult, Never>
    let input: AnySubscriber<CartAction, Never>
    private let _cancellable: AnyCancellable

    init(container: DS.Container?) {
        let actionInput = CurrentValueSubject<CartAction, Never>(.start(with: Cart.empty))
        let cartResult = CurrentValueSubject<CartResult, Never>((Cart.empty, nil))

        _cancellable = actionInput
            .dropFirst()
            .scan((Cart.empty, nil)) { currentCart, action -> CartResult in
                // if case CartAction.start = action {} else {
                dispatchPrecondition(condition: .onQueue(DS.dbQueue))
                // }
                let result = _perform(container, currentCart.cart, action)
                // DLog("performed result:\n", result)
                return result
            }
            // .debug()
            .subscribe(cartResult)

        self.cartResult = cartResult
            .eraseToAnyPublisher()

        input = AnySubscriber<CartAction, Never> {
            $0.request(.unlimited)
        } receiveValue: {
            actionInput.send($0)
            return .unlimited
        } receiveCompletion: {
            DLog("swallowing completion: ", $0)
        }
    }

    deinit {
        _cancellable.cancel()
    }

    func trigger(action: CartAction) -> AnyPublisher<Void, Error> {
        let publisher = cartResult
            .subscribe(on: DS.dbQueue)
            .first()
            .tryMap { cartResult -> Void in
                // DLog("trigger recved:\n", cartResult.cart)
                if let error = cartResult.error {
                    throw error
                }
                return ()
            }

        // DLog("sent value: ", action)
        Just(action)
            .subscribe(on: DS.dbQueue)
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
