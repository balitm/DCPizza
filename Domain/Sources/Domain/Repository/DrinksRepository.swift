//
//  DrinksRepository.swift
//  Domain
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
            .map {
                (try? $0.get().drinks) ?? []
            }
            .removeDuplicates(by: { $0.count == $1.count })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func addToCart(drinkIndex: Int) -> AnyPublisher<Void, Error> {
        _data.$component
            .tryMap {
                try $0.get().drinks.element(at: drinkIndex)
            }
            .flatMap { [unowned data = _data] in
                data.cartHandler.trigger(action: .drink(drink: $0))
            }
            .eraseToAnyPublisher()
    }
}
