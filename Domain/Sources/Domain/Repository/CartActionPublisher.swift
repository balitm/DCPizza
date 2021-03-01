//
//  CartActionPublisher.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/15/20.
//

import Foundation
import Combine

enum CartAction {
    case pizza(pizza: Pizza)
    case drink(drink: Drink)
    case remove(index: Int)
    case empty
    case save
}

extension Publishers {
    struct CartActionPublisher: Publisher {
        typealias Output = Void
        typealias Failure = Error

        private let _action: CartAction
        private let _data: Initializer

        init(data: Initializer, action: CartAction) {
            _action = action
            _data = data
        }

        public func receive<S: Subscriber>(subscriber: S) where Failure == S.Failure, Output == S.Input {
            let subscription = _Subscription(data: _data,
                                             action: _action,
                                             subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

private extension Publishers.CartActionPublisher {
    final class _Subscription<S: Subscriber>: Subscription where S.Input == Publishers.CartActionPublisher.Output, S.Failure == Error {
        private let _action: CartAction
        private let _data: Initializer
        private var _subscriber: S?

        init(data: Initializer, action: CartAction, subscriber: S) {
            _action = action
            _data = data
            _subscriber = subscriber
        }

        func request(_ demand: Subscribers.Demand) {
            _performAction()
        }

        func cancel() {
            _subscriber = nil
        }

        private func _performAction() {
            guard let subscriber = _subscriber else { return }

            func complete(_ completion: Subscribers.Completion<Error>) {
                if case Subscribers.Completion<Error>.finished = completion {
                    _data.cart = _data.cart
                    _ = subscriber.receive(())
                }
                subscriber.receive(completion: completion)
            }

            switch _action {
            case let .pizza(pizza):
                _data.cart.add(pizza: pizza)
                complete(.finished)
            case let .drink(drink):
                _data.cart.add(drink: drink)
                complete(.finished)
            case let .remove(index):
                _data.cart.remove(at: index)
                complete(.finished)
            case .empty:
                _data.cart.empty()
                let completion = _dbAction()
                complete(completion)
            case .save:
                let completion = _dbAction {
                    $0.add(_data.cart.asDataSource())
                }
                complete(completion)
            }
        }

        func _dbAction(_ operation: (DS.WriteTransaction) -> Void = { _ in }) -> Subscribers.Completion<Error> {
            do {
                try _data.container?.write {
                    $0.delete(DS.Pizza.self)
                    $0.delete(DS.Cart.self)
                    operation($0)
                }
                return .finished
            } catch {
                return .failure(error)
            }
        }
    }
}
