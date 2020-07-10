//
//  DrinksTableViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/22/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI
import Domain
import Combine

final class DrinksViewModel: ObservableObject {
    typealias Item = DrinkRowViewModel

    // Input
    @Published var selected = -1

    // Output
    @Published var listData = [DrinkRowViewModel]()
    @Published var showAdded = false

    private var _bag = Set<AnyCancellable>()

    deinit {
        DLog(">>> deinit: ", type(of: self))
    }

    init(service: DrinksUseCase) {
        service.drinks()
            .map({
                $0.enumerated().map { DrinkRowViewModel(name: $0.element.name,
                                                        priceText: format(price: $0.element.price),
                                                        index: $0.offset) }
            })
            .assign(to: \.listData, on: self)
            .store(in: &_bag)

        $selected
            .flatMap({
                service.addToCart(drinkIndex: $0)
                    .catch({ _ in Empty<Void, Never>() })
            })
            .map({ true })
            .assign(to: \.showAdded, on: self)
            .store(in: &_bag)
    }
}
