//
//  CartRepository.swift
//
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

    func items() -> AnyPublisher<[Cart.Item], Never> {
        _data.$cart
            .map { $0.items() }
            .eraseToAnyPublisher()
    }

    func total() -> AnyPublisher<Double, Never> {
        _data.$cart
            .map { $0.totalPrice() }
            .eraseToAnyPublisher()
    }

    func remove(at index: Int) -> AnyPublisher<Void, Error> {
        Publishers.CartActionPublisher(data: _data, action: .remove(index: index))
            .eraseToAnyPublisher()
    }

    func checkout() -> AnyPublisher<Void, API.ErrorType> {
        _data.$cart
            .first()
            .mapError({ _ in
                API.ErrorType.processingFailed
            })
            .flatMap({ [unowned data = _data] in
                data.network.checkout(cart: $0.asDataSource())
                    .zip(
                        Publishers.CartActionPublisher(data: data, action: .empty)
                            .mapError({
                                DLog("Error received emptying the cart: ", $0)
                                return API.ErrorType.processingFailed
                            })
                    ) { _, _ in
                        ()
                    }
//                    .print()
            })
            .eraseToAnyPublisher()
    }
}
