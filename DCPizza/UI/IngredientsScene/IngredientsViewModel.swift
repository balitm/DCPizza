//
//  IngredientsTableViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/19/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain
import RxSwift
import RxDataSources
import struct RxCocoa.Driver

struct IngredientsViewModel: ViewModelType {
    struct Input {
        let addEvent: Observable<Void>
    }

    struct Output {
        let title: Driver<String>
        let tableData: Driver<[SectionModel]>
        let cartText: Driver<String>
        let showAdded: Driver<Void>
    }

    var resultCart: Observable<Cart> { cart.asObservable().skip(1) }
    private let _pizza: Pizza
    private let _image: UIImage?
    private let _ingredients: [Ingredient]
    let cart: BehaviorSubject<Cart>
    private let _bag = DisposeBag()

    init(pizza: Pizza, image: UIImage?, ingredients: [Ingredient], cart: Cart) {
        _pizza = pizza
        _image = image
        _ingredients = ingredients
        self.cart = BehaviorSubject(value: cart)
    }

    func transform(input: Input) -> Output {
        func isContained(_ ingredient: Domain.Ingredient) -> Bool {
            return _pizza.ingredients.contains { $0.id == ingredient.id }
        }

        var items: [SectionItem] = [.header(viewModel: IngredientsHeaderCellViewModel(image: _image))]
        let vms = _ingredients.map { ing -> SectionItem in
            .ingredient(viewModel: IngredientsItemCellViewModel(
                name: ing.name,
                priceText: "$\(ing.price)",
                isContained: isContained(ing)))
        }
        items.append(contentsOf: vms)

        // Add pizza to cart.
        input.addEvent
            .withLatestFrom(cart) { $1 }
            .map({
                var newCart = $0
                newCart.add(pizza: self._pizza)
                return newCart
            })
            .bind(to: cart)
            .disposed(by: _bag)

        let sum = _pizza.ingredients.reduce(0.0, { $0 + $1.price })
        let cartText = "ADD TO CART ($\(sum))"
        return Output(title: Driver.just(_pizza.name.uppercased()),
                      tableData: Driver.just([SectionModel(items: items)]),
                      cartText: Driver.just(cartText),
                      showAdded: input.addEvent.asDriver(onErrorJustReturn: ()))
    }
}

extension IngredientsViewModel {
    struct SectionModel {
        var items: [Item]
    }

    enum SectionItem {
        case header(viewModel: IngredientsHeaderCellViewModel)
        case ingredient(viewModel: IngredientsItemCellViewModel)
    }
}

extension IngredientsViewModel.SectionModel: SectionModelType {
    typealias Item = IngredientsViewModel.SectionItem

    init(original: IngredientsViewModel.SectionModel, items: [Item]) {
        self.items = items
    }
}
