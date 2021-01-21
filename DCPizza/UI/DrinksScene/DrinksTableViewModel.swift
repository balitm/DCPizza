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
import struct RxCocoa.Driver
import Resolver

struct DrinksTableViewModel: ViewModelType {
    typealias Item = DrinkCellViewModel

    struct Input {
        let selected: Observable<Int>
    }

    struct Output {
        let tableData: Driver<[Item]>
        let showAdded: Driver<Void>
    }

    @Injected private var _service: DrinksUseCase

    func transform(input: Input) -> Output {
        let items = _service.drinks()
            .map {
                $0.map { DrinkCellViewModel(name: $0.name, priceText: format(price: $0.price)) }
            }

        // Add drink to cart.
        let showAdded = input.selected
            .flatMapLatest { [service = _service] in
                service.addToCart(drinkIndex: $0)
                    .catch { _ in Completable.never() }
                    .andThen(Observable.just(()))
            }

        return Output(tableData: items.asDriver(onErrorJustReturn: []),
                      showAdded: showAdded.asDriver(onErrorJustReturn: ()))
    }
}
