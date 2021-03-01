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
import Resolver

final class DrinksViewModel: ObservableObject {
    typealias Item = DrinkRowViewModel

    // Output
    @Published var listData = [DrinkRowViewModel]()
    @Published var showAdded = false

    @Injected private var _service: DrinksUseCase
    private var _bag = Set<AnyCancellable>()

    deinit {
        DLog(">>> deinit: ", type(of: self))
    }

    init() {
        DLog(">>> init: ", type(of: self))

        _service.drinks()
            .map {
                $0.enumerated().map {
                    DrinkRowViewModel(name: $0.element.name,
                                      priceText: format(price: $0.element.price),
                                      index: $0.offset)
                }
            }
            .assign(to: \.listData, on: self)
            .store(in: &_bag)
    }

    /// Remove the indexed item.
    /// - Parameter index: index of the item to remove.
    func removeFromCart(index: Int) {
        Just(index)
            .flatMap { [service = _service] in
                service.addToCart(drinkIndex: $0)
                    .catch { _ in Empty<Void, Never>() }
            }
            .map { true }
            .assign(to: \.showAdded, on: self)
            .store(in: &_bag)
    }
}
