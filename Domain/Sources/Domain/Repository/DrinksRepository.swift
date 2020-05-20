//
//  DrinksRepository.swift
//
//
//  Created by Balázs Kilvády on 5/20/20.
//

import Foundation
import Combine

struct DrinksRepository: DrinksUseCase {
    private let _data: Initializer

    init(data: Initializer) {
        _data = data
    }

    func drinks() -> AnyPublisher<[Drink], Never> {
        _data.$component
            .tryMap({
                try $0.get().drinks
            })
            .catch({ _ in
                Empty<[Drink], Never>()
            })
            .first()
            .eraseToAnyPublisher()
    }

    func addToCart(drinkIndex: Int) -> AnyPublisher<Void, Error> {
        _data.$component
            .tryMap({
                try $0.get().drinks.element(at: drinkIndex)
            })
            .flatMap({ [unowned data = _data] in
                Publishers.CartActionPublisher(data: data, action: .drink(drink: $0))
            })
            .first()
            .eraseToAnyPublisher()
    }
}
