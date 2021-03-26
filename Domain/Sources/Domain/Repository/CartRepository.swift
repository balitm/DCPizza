//
//  CartRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/16/20.
//

import Foundation
import Combine

struct CartRepository: CartUseCase {
    private let _data: Initializer

    init(data: Initializer) {
        _data = data
    }

    func items() -> AnyPublisher<[CartItem], Never> {
        _data.cartHandler.cart
            .filter { $0.error == nil }
            .map { $0.cart.items() }
            .eraseToAnyPublisher()
    }

    func total() -> AnyPublisher<Double, Never> {
        _data.cartHandler.cart
            .map { $0.cart.totalPrice() }
            .eraseToAnyPublisher()
    }

    func remove(at index: Int) -> AnyPublisher<Void, Error> {
        _data.cartHandler.trigger(action: .remove(index: index))
    }

    func checkout() -> AnyPublisher<Void, API.ErrorType> {
        _data.cartHandler.cart
            .first()
            .map(\.cart)
            .mapError({ _ in
                API.ErrorType.processingFailed
            })
            .flatMap({ [unowned data = _data] in
                data.network.checkout(cart: $0.asDataSource())
                    .zip(data.cartHandler.trigger(action: .empty)
                        .mapError({
                            DLog("Error received emptying the cart: ", $0)
                            return API.ErrorType.processingFailed
                        })
                    ) { _, _ in () }
            })
            .eraseToAnyPublisher()
    }
}
