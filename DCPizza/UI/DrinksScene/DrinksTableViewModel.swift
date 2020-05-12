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

final class DrinksTableViewModel: ViewModelType {
    typealias Item = DrinkCellViewModel

    struct Input {
        let selected: AnyPublisher<Int, Never>
    }

    struct Output {
        let tableData: AnyPublisher<[Item], Never>
        let showAdded: AnyPublisher<Void, Never>
    }

    var resultCart: AnyPublisher<Cart, Never> { cart.dropFirst().eraseToAnyPublisher() }
    let cart: CurrentValueSubject<Cart, Never>
    private let _drinks: [Drink]
    private var _bag = Set<AnyCancellable>()

    init(drinks: [Drink], cart: Cart) {
        _drinks = drinks
        self.cart = CurrentValueSubject(cart)
    }

    func transform(input: Input) -> Output {
        let items = _drinks.map {
            DrinkCellViewModel(name: $0.name, priceText: format(price: $0.price))
        }
        let selected = input.selected.share()

        // Add drink to cart.
        selected
            .flatMap({ [unowned cart] index in
                cart
                    .first()
                    .map({ (index: index, cart: $0) })
            })
            // .print()
            .map({ [drinks = _drinks] in
                var newCart = $0.cart
                newCart.add(drink: drinks[$0.index])
                return newCart
            })
            .bind(subscriber: AnySubscriber(cart))
            .store(in: &_bag)

        let showAdded = selected
            .map { _ in () }

        return Output(tableData: Just(items).eraseToAnyPublisher(),
                      showAdded: showAdded.eraseToAnyPublisher())
    }
}
