//
//  CartActionPublisher.swift
//
//
//  Created by Balázs Kilvády on 5/15/20.
//

import Foundation
import Combine

enum CartAction {
    case pizza(pizza: Pizza)
    case drink(drink: Drink)
    case save
}

extension Publishers {
    private final class _CartSubscription<S: Subscriber>: Subscription where S.Input == Void, S.Failure == Error {
        private let _action: CartAction
        private let _data: Initializer
        private var _subscriber: S?

        init(data: Initializer, action: CartAction, subscriber: S) {
            _action = action
            _data = data
            _subscriber = subscriber
            _performAction()
        }

        func request(_ demand: Subscribers.Demand) {
            // TODO: - Optionaly Adjust The Demand
        }

        func cancel() {
            _subscriber = nil
        }

        private func _performAction() {
            guard let subscriber = _subscriber else { return }

            switch _action {
            case let .pizza(pizza):
                _data.cart.add(pizza: pizza)
                subscriber.receive(completion: .finished)
            case let .drink(drink):
                _data.cart.add(drink: drink)
                subscriber.receive(completion: .finished)
            case .save:
                do {
                    try _data.container?.write({
                        $0.delete(DS.Cart.self)
                        $0.add(_data.cart.asDataSource())
                    })
                    subscriber.receive(completion: .finished)
                } catch {
                    subscriber.receive(completion: .failure(error))
                }
            }
        }
    }

    struct CartActionPublisher: Publisher {
        typealias Output = Void
        typealias Failure = Error

        private let _action: CartAction
        private let _data: Initializer

        init(data: Initializer, action: CartAction) {
            _action = action
            _data = data
        }

        func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            let subscription = _CartSubscription(data: _data,
                                                 action: _action,
                                                 subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}
