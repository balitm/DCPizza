//
//  MenuTableViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain
import Combine
import class UIKit.UIImage

class MenuTableViewModel: ViewModelType {
    typealias DrinksData = (cart: UI.Cart, drinks: [Drink])
    typealias Selected = (index: Int, image: UIImage?)
    typealias Selection = (
        pizza: Pizza,
        image: UIImage?,
        ingredients: [Ingredient],
        cart: UI.Cart
    )

    struct Input {
        let selected: AnyPublisher<Selected, Never>
        let scratch: AnyPublisher<Void, Never>
        let cart: AnyPublisher<Void, Never>
//        let saveCart: AnyPublisher<Void, Never>
    }

    struct Output {
        let tableData: AnyPublisher<[MenuCellViewModel], Never>
        let selection: AnyPublisher<Selection, Never>
        let showAdded: AnyPublisher<Void, Never>
        let showCart: AnyPublisher<DrinksData, Never>
    }

    @Published var cart = UI.Cart.empty

    private let _networkUseCase: NetworkUseCase
    private let _databaseUseCase: DatabaseUseCase
    private var _bag = Set<AnyCancellable>()

    init(networkUseCase: NetworkUseCase, databaseUseCase: DatabaseUseCase) {
        _networkUseCase = networkUseCase
        _databaseUseCase = databaseUseCase
    }

    func transform(input: Input) -> Output {
        let cachedData = CurrentValueSubject<InitData, Never>(InitData.empty)
        _networkUseCase.getInitData()
            .catch({ _ in
                Empty<InitData, Never>()
            })
            .bind(subscriber: AnySubscriber(cachedData))
            .store(in: &_bag)

        let viewModels = cachedData
            .map({ data -> [MenuCellViewModel] in
                let basePrice = data.pizzas.basePrice
                let vms = data.pizzas.pizzas.map {
                    MenuCellViewModel(basePrice: basePrice, pizza: $0)
                }
                return vms
            })
            .share()

        // Init the cart.
        cachedData
            .map({ $0.cart.asUI() })
            .assign(to: \.cart, on: self)
            .store(in: &_bag)

        let cartEvents = viewModels
            .map({ vms in
                vms.enumerated().map({ pair in
                    pair.element.tap
                        .map({ _ in
                            pair.offset
                        })
                })
            })
            .flatMap({
                Publishers.MergeMany($0)
                    .handleEvents(receiveOutput: {
                        DLog("recved pair: ", $0)
                    }, receiveCompletion: {
                        DLog("completion: ", $0)
                    }, receiveCancel: {
                        DLog("cancel")
                    })
            })
            .share()

        // Update cart on add events.
        cartEvents
            .flatMap({ [unowned self] (idx: Int) in
                Publishers.Zip(cachedData, self.$cart)
                    .map({ (cmb: (data: InitData, cart: UI.Cart)) -> UI.Cart in
                        var newCart = cmb.cart
                        newCart.add(pizza: cmb.data.pizzas.pizzas[idx])
                        return newCart
                    })
            })
            // .debug(trimOutput: true)
            .assign(to: \.cart, on: self)
            .store(in: &_bag)

        // A pizza is selected.
        let selected = input.selected
            .flatMap({ [unowned self] selected in
                Publishers.Zip(cachedData, self.$cart)
                    .map({ (data: $0.0, selected: selected, cart: $0.1) })
                    .first()
            })
            .map({ t -> Selection in
                let pizza = t.data.pizzas.pizzas[t.selected.index]
                let image = t.selected.image
                let ingredients = t.data.ingredients
                return (pizza, image, ingredients, t.cart)
            })

        // Pizza from scratch is selected.
        let scratch = input.scratch
            .flatMap({ [unowned self] selected in
                Publishers.Zip(cachedData, self.$cart)
                    .first()
            })
            .map({ (t: (data: InitData, cart: UI.Cart)) -> Selection in
                let pizza = Pizza()
                let ingredients = t.data.ingredients
                return (pizza, nil, ingredients, t.cart)
            })

        let selection = Publishers.Merge(selected, scratch)

        let showCart = input.cart
            .flatMap({
                Publishers.Zip(cachedData, self.$cart)
            })
            .map({ (t: (data: InitData, cart: UI.Cart)) -> DrinksData in
                (t.cart, t.data.drinks)
            })

//        input.saveCart
//            .withLatestFrom(cart)
//            .subscribe(onNext: { [dbUseCase = _databaseUseCase] in
//                // DLog("save cart, pizzas: ", $0.pizzas.count, ", drinks: ", $0.drinks.count)
//                dbUseCase.save(cart: $0.asDomain())
//            })
//            .disposed(by: _bag)

        let showAdded = cartEvents.map({ _ in () })

        return Output(tableData: viewModels.eraseToAnyPublisher(),
                      selection: selection.eraseToAnyPublisher(),
                      showAdded: showAdded.eraseToAnyPublisher(),
                      showCart: showCart.eraseToAnyPublisher()
        )
    }
}
