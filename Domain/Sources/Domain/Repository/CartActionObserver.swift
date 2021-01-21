//
//  CartActionObserver.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/15/20.
//

import Foundation
import RxSwift

enum CartAction {
    case pizza(pizza: Pizza)
    case drink(drink: Drink)
    case remove(index: Int)
    case empty
    case save
}

extension Initializer {
    func cartActionCompletable(action: CartAction) -> Completable {
        Completable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            var cart = self.cart.value

            func complete(_ error: Error? = nil) {
                if let error = error {
                    observer(.error(error))
                } else {
                    self.cart.accept(cart)
                    observer(.completed)
                }
            }

            func dbAction(_ operation: (DS.WriteTransaction) -> Void = { _ in }) -> Error? {
                do {
                    try self.container?.write {
                        $0.delete(DS.Pizza.self)
                        $0.delete(DS.Cart.self)
                        operation($0)
                    }
                    return nil
                } catch {
                    return error
                }
            }

            switch action {
            case let .pizza(pizza):
                cart.add(pizza: pizza)
                complete()
            case let .drink(drink):
                cart.add(drink: drink)
                complete()
            case let .remove(index):
                cart.remove(at: index)
                complete()
            case .empty:
                cart.empty()
                let completion = dbAction()
                complete(completion)
            case .save:
                let completion = dbAction {
                    $0.add(cart.asDataSource())
                }
                complete(completion)
            }

            return Disposables.create()
        }
    }
}
