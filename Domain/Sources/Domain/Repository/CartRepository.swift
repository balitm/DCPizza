//
//  CartRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/16/20.
//

import Foundation
import RxSwift

struct CartRepository: CartUseCase {
    private let _data: Initializer

    init(data: Initializer) {
        _data = data
    }

    func items() -> Observable<[CartItem]> {
        _data.cart
            .map { $0.items() }
    }

    func total() -> Observable<Double> {
        _data.cart
            .map { $0.totalPrice() }
    }

    func remove(at index: Int) -> Completable {
        _data.cartActionCompletable(action: .remove(index: index))
    }

    func checkout() -> Completable {
        _data.cart
            .take(1)
            .flatMap { [unowned data = _data] in
                Completable.zip(data.network.checkout(cart: $0.asDataSource()),
                                data.cartActionCompletable(action: .empty)
                )
            }
            .ignoreElements()
            .asCompletable()
    }
}
