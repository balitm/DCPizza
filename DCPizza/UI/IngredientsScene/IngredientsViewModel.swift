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
        let selected: Observable<Int>
        let addEvent: Observable<Void>
    }

    struct Output {
        let title: Driver<String>
        let tableData: Driver<[SectionModel]>
        let cartText: Driver<String>
        let showAdded: Driver<Void>
    }

    var resultCart: Observable<UI.Cart> { cart.asObservable().skip(1) }
    private let _pizza: BehaviorSubject<Pizza>
    private let _image: UIImage?
    private let _ingredients: [Ingredient]
    let cart: BehaviorSubject<UI.Cart>
    private let _bag = DisposeBag()

    init(pizza: Pizza, image: UIImage?, ingredients: [Ingredient], cart: UI.Cart) {
        _pizza = BehaviorSubject(value: pizza)
        _image = image
        _ingredients = ingredients
        self.cart = BehaviorSubject(value: cart)
    }

    func transform(input: Input) -> Output {
        let items = _createItems()

        let models = Observable<[SectionModel]>.create { observer in
            observer.onNext([SectionModel(items: items)])
            var ings = items

            let disp = input.selected
                .map({ idx -> [SectionModel] in
                    guard case let SectionItem.ingredient(row, viewModel) = ings[idx] else {
                        return [SectionModel(items: items)]
                    }
                    assert(row == idx)
                    let newVM = IngredientsItemCellViewModel(
                        name: viewModel.name,
                        priceText: viewModel.priceText,
                        isContained: !viewModel.isContained)
                    DLog("replace at ", idx, " ", viewModel.name, " - ", viewModel.isContained,
                         " to ", newVM.name, " - ", newVM.isContained)
                    ings[idx] = .ingredient(row: row, viewModel: newVM)
                    return [SectionModel(items: ings)]
                })
                .do(onNext: { observer.onNext($0) })
                .subscribe()

            return disp
        }

        // Add pizza to cart.
        input.addEvent
            .withLatestFrom(Observable.combineLatest(cart, _pizza)) { (cart: $1.0, pizza: $1.1) }
            .map({
                var newCart = $0.cart
                newCart.add(pizza: $0.pizza)
                return newCart
            })
            .bind(to: cart)
            .disposed(by: _bag)

//        // Toggle ingredient.
//        input.selected
//            .map({ self._ingredients[$0 - 1]}

        let title = _pizza
            .map({ $0.name == "sketch" ? "CREATE A PIZZA" : $0.name.uppercased() })
            .asDriver(onErrorJustReturn: "")

        let sum = (try? _pizza.value().ingredients.reduce(0.0, { $0 + $1.price })) ?? 0
        let cartText = "ADD TO CART ($\(sum))"
        return Output(title: title,
                      tableData: models.asDriver(onErrorJustReturn: []),
                      cartText: Driver.just(cartText),
                      showAdded: input.addEvent.asDriver(onErrorJustReturn: ()))
    }

    private func _createItems() -> [SectionItem] {
        func isContained(_ ingredient: Domain.Ingredient) -> Bool {
            return (try? _pizza.value().ingredients.contains { $0.id == ingredient.id }) ?? false
        }

        var items: [SectionItem] = [.header(viewModel: IngredientsHeaderCellViewModel(image: _image))]
        let vms = _ingredients.enumerated().map { ing -> SectionItem in
            .ingredient(
                row: 1 + ing.offset,
                viewModel: IngredientsItemCellViewModel(
                    name: ing.element.name,
                    priceText: format(price: ing.element.price),
                    isContained: isContained(ing.element)
                )
            )
        }
        items.append(contentsOf: vms)
        return items
    }
}

extension IngredientsViewModel {
    struct SectionModel {
        var items: [Item]
    }

    enum SectionItem {
        case header(viewModel: IngredientsHeaderCellViewModel)
        case ingredient(row: Int, viewModel: IngredientsItemCellViewModel)
    }
}

extension IngredientsViewModel.SectionModel: AnimatableSectionModelType {
    typealias Item = IngredientsViewModel.SectionItem

    var identity: Int { return 0 }

    init(original: IngredientsViewModel.SectionModel, items: [IngredientsViewModel.SectionItem]) {
        self = original
        self.items = items
    }
}

extension IngredientsViewModel.SectionItem: IdentifiableType, Equatable {
    var identity: Int {
        switch self {
        case .header:
            return 0
        case let .ingredient(row, _):
            return row
        }
    }

    var unique: Bool {
        switch self {
        case .header:
            return false
        case let .ingredient(_, viewModel):
            return viewModel.isContained
        }
    }

    static func ==(lhs: IngredientsViewModel.SectionItem, rhs: IngredientsViewModel.SectionItem) -> Bool {
        return lhs.identity == rhs.identity && lhs.unique == rhs.unique
    }
}
