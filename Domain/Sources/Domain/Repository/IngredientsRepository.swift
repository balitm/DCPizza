//
//  IngredientsRepository.swift
//
//
//  Created by Balázs Kilvády on 5/16/20.
//

import Foundation
import Combine

struct IngredientsRepository: IngredientsUseCase {
    private let _data: Initializer

    init(data: Initializer) {
        _data = data
    }

    func ingredients() -> AnyPublisher<[Ingredient], Never> {
        _data.$component
            .tryMap({
                try $0.get().ingredients
            })
            .catch({ _ in
                Empty<[Ingredient], Never>()
            })
            .eraseToAnyPublisher()
    }

    func add(pizza: Pizza) -> AnyPublisher<Void, Error> {
        Publishers.CartActionPublisher(data: _data, action: .pizza(pizza: pizza)).eraseToAnyPublisher()
    }
}
