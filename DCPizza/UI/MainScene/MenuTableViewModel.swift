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
    typealias Selected = (index: Int, image: UIImage?)
    typealias Selection = (
        pizza: Pizza,
        image: UIImage?,
        ingredients: [Ingredient],
        cart: Cart
    )

    struct Input {
        let selected: Observable<Selected>
    }

    struct Output {
        let tableData: Driver<[SectionModel]>
        let selection: Driver<Selection>
        let showAdded: Driver<Void>
    }

    let cart = PublishRelay<Cart>()
    private let _bag = DisposeBag()

    func transform(input: Input) -> Output {
        let useCase = RepositoryNetworkUseCaseProvider().makeNetworkUseCase()
        let data = useCase.getInitData().share()

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
            .take(1)
            .map({ $0.cart })
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
            .withLatestFrom(Observable.combineLatest(data, cart), resultSelector: { (cart: $1.1, data: $1.0, idx: $0) })
//            .debug(trimOutput: true)
            .map({
                var newCart = $0.cart
                newCart.add(pizza: $0.data.pizzas.pizzas[$0.idx])
                DLog("new cart, pizzas: ", newCart.pizzas.count, ", drinks: ", newCart.drinks.count)
                return newCart
            })
            .bind(to: cart)
            .disposed(by: _bag)

        let sections = viewModels
            .map({ [SectionModel(items: $0)] })
            .asDriver(onErrorJustReturn: [])

        let selection = input.selected
            .withLatestFrom(Observable.combineLatest(data, cart), resultSelector: { (data: $1.0, selected: $0, cart: $1.1) })
            .map({ t -> Selection in
                let pizza = t.data.pizzas.pizzas[t.selected.index]
                let image = t.selected.image
                let ingredients = t.data.ingredients
                return (pizza, image, ingredients, t.cart)
            })
            .asDriver(onErrorDriveWith: Driver<Selection>.never())

        return Output(tableData: sections,
                      selection: selection,
                      showAdded: cartEvents.map { _ in () }.asDriver(onErrorJustReturn: ()))
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
