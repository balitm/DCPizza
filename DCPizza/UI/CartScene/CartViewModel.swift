//
//  CartViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain
import Combine

final class CartViewModel: ViewModelType {
    typealias DrinksData = (cart: UI.Cart, drinks: [Drink])

    enum Item: Hashable {
        case padding(viewModel: PaddingCellViewModel)
        case item(viewModel: CartItemCellViewModel)
        case total(viewModel: CartTotalCellViewModel)
    }

    struct Input {
        let selected: AnyPublisher<Int, Never>
        let checkout: AnyPublisher<Void, Never>
    }

    struct Output {
        let tableData: AnyPublisher<[Item], Never>
        let showSuccess: AnyPublisher<Void, Never>
        let showDrinks: AnyPublisher<DrinksData, Never>
        let canCheckout: AnyPublisher<Bool, Never>
    }

    var resultCart: AnyPublisher<UI.Cart, Never> { cart.dropFirst().eraseToAnyPublisher() }
    let cart: CurrentValueSubject<UI.Cart, Never>

    private let _networkUseCase: NetworkUseCase
    private let _drinks: [Drink]
    private var _bag = Set<AnyCancellable>()

    init(networkUseCase: NetworkUseCase, cart: UI.Cart, drinks: [Drink]) {
        self.cart = CurrentValueSubject<UI.Cart, Never>(cart)
        _networkUseCase = networkUseCase
        _drinks = drinks
    }

    func transform(input: Input) -> Output {
        let models = cart
            .map({ cart -> [Item] in
                var items = [Item.padding(viewModel: PaddingCellViewModel(height: 12))]
                let pizzas = cart.pizzas.enumerated().map {
                    Item.item(viewModel: CartItemCellViewModel(pizza: $0.element,
                                                               basePrice: cart.basePrice,
                                                               id: cart.pizzaIds[$0.offset])
                    )
                }
                let drinks = cart.drinks.enumerated().map {
                    Item.item(viewModel: CartItemCellViewModel(drink: $0.element,
                                                               id: cart.drinkIds[$0.offset])
                    )
                }
                items.append(contentsOf: pizzas)
                items.append(contentsOf: drinks)
                items.append(.padding(viewModel: PaddingCellViewModel(height: 24)))
                items.append(.total(viewModel: CartTotalCellViewModel(price: cart.totalPrice())))
                return items
            })

        input.selected
            .flatMap({ [unowned cart] index in
                cart
                    .first()
                    .map({
                        assert(index >= 1)
                        let idx = index - 1

                        // DLog(">>> index: ", index)
                        var newCart = $0
                        newCart.remove(at: idx)
                        // DLog(">>> pizzas in cart: ", newCart.pizzas.count)
                        return newCart
                    })
            })
            .bind(subscriber: AnySubscriber(cart))
            .store(in: &_bag)

        let checkout = input.checkout
            .flatMap({ [unowned cart] _ in cart.first() })
            .flatMap({ [useCase = _networkUseCase] uiCart in
                useCase.checkout(cart: uiCart.asDomain())
                    .map { uiCart }
                    .catch({ _ in Just(uiCart) })
            })
            .share()

        checkout
            .map({
                var newCart = $0
                newCart.empty()
                return newCart
            })
            .bind(subscriber: AnySubscriber(cart))
            .store(in: &_bag)

        let showDrinks = cart
            .map({ [drinks = _drinks] in (cart: $0, drinks: drinks) })

        let canCheckout = cart
            .map({ !$0.isEmpty })

        return Output(
            tableData: models.eraseToAnyPublisher(),
            showSuccess: checkout
                .map({ _ in () })
                .eraseToAnyPublisher(),
            showDrinks: showDrinks.eraseToAnyPublisher(),
            canCheckout: canCheckout.eraseToAnyPublisher()
        )
    }
}
