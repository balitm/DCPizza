//
//  DrinksTableViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/22/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain
import RxSwift
import RxDataSources
import struct RxCocoa.Driver

struct DrinksTableViewModel: ViewModelType {
    struct Input {
        let selected: Observable<Int>
    }

    struct Output {
        let tableData: Driver<[SectionModel]>
        let showAdded: Driver<Void>
    }

    var resultCart: Observable<UI.Cart> { cart.asObservable().skip(1) }
    let cart: BehaviorSubject<UI.Cart>
    private let _drinks: [Drink]
    private let _bag = DisposeBag()

    init(drinks: [Drink], cart: UI.Cart) {
        _drinks = drinks
        self.cart = BehaviorSubject(value: cart)
    }

    func transform(input: Input) -> Output {
        let items = _drinks.map {
            DrinkCellViewModel(name: $0.name, priceText: format(price: $0.price))
        }

        // Add drink to cart.
        input.selected
            .withLatestFrom(cart) { (index: $0, cart: $1) }
            .map({ [drinks = _drinks] in
                var newCart = $0.cart
                newCart.add(drink: drinks[$0.index])
                return newCart
            })
            .bind(to: cart)
            .disposed(by: _bag)

        let showAdded = input.selected
            .map { _ in () }
            .asDriver(onErrorJustReturn: ())

        return Output(tableData: Driver.just([SectionModel(items: items)]),
                      showAdded: showAdded)
    }
}

extension DrinksTableViewModel {
    typealias SectionItem = DrinkCellViewModel

    struct SectionModel {
        var items: [SectionItem]
    }
}

extension DrinksTableViewModel.SectionModel: SectionModelType {
    typealias Item = DrinksTableViewModel.SectionItem

    init(original: DrinksTableViewModel.SectionModel, items: [Item]) {
        self.items = items
    }
}
