//
//  MenuRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/14/20.
//

import Foundation
import RxSwift

struct MenuRepository: MenuUseCase {
    private let _data: Initializer

    init(data: Initializer) {
        _data = data
    }

    func pizzas() -> Observable<PizzasResult> {
        _data.component
            .compactMap {
                try? $0.get()
            }
            .map { components in
                PizzasResult.success(components.pizzas)
            }
    }

    func addToCart(pizza: Pizza) -> Completable {
        _data.cartActionCompletable(action: .pizza(pizza: pizza))
    }
}
