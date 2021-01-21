//
//  DrinksTableViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/22/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain
import Combine

struct DrinksTableViewModel: ViewModelType {
    typealias Item = DrinkCellViewModel

    struct Input {
        let selected: AnyPublisher<Int, Never>
    }

    struct Output {
        let tableData: AnyPublisher<[Item], Never>
        let showAdded: AnyPublisher<Void, Never>
    }

    private let _service: DrinksUseCase

    init(service: DrinksUseCase) {
        _service = service
    }

    func transform(input: Input) -> Output {
        let items = _service.drinks()
            .map {
                $0.map { DrinkCellViewModel(name: $0.name, priceText: format(price: $0.price)) }
            }

        // Add drink to cart.
        let showAdded = input.selected
            .flatMap { [service = _service] in
                service.addToCart(drinkIndex: $0)
                    .catch { _ in Empty<Void, Never>() }
            }

        return Output(tableData: items.eraseToAnyPublisher(),
                      showAdded: showAdded.eraseToAnyPublisher())
    }
}
