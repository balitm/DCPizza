//
//  MenuTableViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain
import RxSwift
import RxDataSources
import RxRelay
import struct RxCocoa.Driver
import class UIKit.UIImage

struct MenuTableViewModel: ViewModelType {
    typealias DrinksData = (cart: UI.Cart, drinks: [Drink])
    typealias Selected = (index: Int, image: UIImage?)
    typealias Selection = (
        pizza: Pizza,
        image: UIImage?,
        ingredients: [Ingredient],
        cart: UI.Cart
    )

    struct Input {
        let selected: Observable<Selected>
        let scratch: Observable<Void>
        let cart: Observable<Void>
        let saveCart: Observable<Void>
    }

    struct Output {
        let tableData: Driver<[SectionModel]>
        let selection: Driver<Selection>
        let showAdded: Driver<Void>
        let showCart: Driver<DrinksData>
    }

    let cart = PublishRelay<UI.Cart>()
    private let _networkUseCase: NetworkUseCase
    private let _databaseUseCase: DatabaseUseCase
    private let _bag = DisposeBag()

    init(networkUseCase: NetworkUseCase, databaseUseCase: DatabaseUseCase) {
        _networkUseCase = networkUseCase
        _databaseUseCase = databaseUseCase
    }

    func transform(input: Input) -> Output {
        let data = _networkUseCase
            .getInitData()
            .catchErrorJustComplete()
            .share()

        let viewModels = data
            .map({ data -> [MenuCellViewModel] in
                let basePrice = data.pizzas.basePrice
                let vms = data.pizzas.pizzas.map {
                    MenuCellViewModel(basePrice: basePrice, pizza: $0)
                }
                return vms
            })
            .share()

        // Init the cart.
        data
            .map({ $0.cart.asUI() })
            .bind(to: cart)
            .disposed(by: _bag)

        let cartEvents = viewModels
            .map({ vm in
                vm.enumerated().map({ pair in
                    pair.element.tap
                        .map({ _ in
                            pair.offset
                        })
                })
            })
            .flatMap({
                Observable.merge($0)
            })

        // Update cart.
        cartEvents
            .withLatestFrom(Observable.combineLatest(data, cart)) { (cart: $1.1, data: $1.0, idx: $0) }
            // .debug(trimOutput: true)
            .map({
                var newCart = $0.cart
                newCart.add(pizza: $0.data.pizzas.pizzas[$0.idx])
                return newCart
            })
            .bind(to: cart)
            .disposed(by: _bag)

        let sections = viewModels
            .map({ [SectionModel(items: $0)] })
            .asDriver(onErrorJustReturn: [])

        // A pizza is selected.
        let selected = input.selected
            .withLatestFrom(Observable.combineLatest(data, cart)) { (data: $1.0, selected: $0, cart: $1.1) }
            .map({ t -> Selection in
                let pizza = t.data.pizzas.pizzas[t.selected.index]
                let image = t.selected.image
                let ingredients = t.data.ingredients
                return (pizza, image, ingredients, t.cart)
            })

        // Pizza from scratch is selected.
        let scratch = input.scratch
            .withLatestFrom(Observable.combineLatest(data, cart)) { (data: $1.0, cart: $1.1) }
            .map({ t -> Selection in
                let pizza = Pizza()
                let ingredients = t.data.ingredients
                return (pizza, nil, ingredients, t.cart)
            })

        let selection = Observable.merge(selected, scratch)
            .asDriver(onErrorDriveWith: Driver<Selection>.never())

        let showCart = input.cart
            .withLatestFrom(Observable.combineLatest(data, cart), resultSelector: { (data: $1.0, cart: $1.1) })
            .map({ t -> DrinksData in
                (t.cart, t.data.drinks)
            })
            .asDriver(onErrorDriveWith: Driver<DrinksData>.never())

        input.saveCart
            .withLatestFrom(cart)
            .subscribe(onNext: { [dbUseCase = _databaseUseCase] in
                // DLog("save cart, pizzas: ", $0.pizzas.count, ", drinks: ", $0.drinks.count)
                dbUseCase.save(cart: $0.asDomain())
            })
            .disposed(by: _bag)

        return Output(tableData: sections,
                      selection: selection,
                      showAdded: cartEvents.map { _ in () }.asDriver(onErrorJustReturn: ()),
                      showCart: showCart
        )
    }
}

extension MenuTableViewModel {
    struct SectionModel {
        var items: [MenuCellViewModel]
    }
}

extension MenuTableViewModel.SectionModel: SectionModelType {
    typealias Item = MenuCellViewModel

    init(original: MenuTableViewModel.SectionModel, items: [Item]) {
        self.items = items
    }
}
