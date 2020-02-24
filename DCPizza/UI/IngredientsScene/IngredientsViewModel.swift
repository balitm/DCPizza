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
    typealias Selected = (isOn: Bool, ingredient: Ingredient)

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
        let items = _createSels()

        // Create selections observable.
        let sels = Observable<[Selected]>.create { observer in
            observer.onNext(items)
            var ings = items

            let disp = input.selected
                .filter({ $0 >= 1 })
                .map({ i -> [Selected] in
                    let idx = i - 1
                    let item = ings[idx]
                    ings[idx] = (!item.isOn, item.ingredient)
                    DLog("replace at ", idx, " ", item.ingredient.name, " - ", item.isOn,
                         " to ", !item.isOn)
                    return ings
                })
                .do(onNext: { observer.onNext($0) })
                .subscribe()

            return disp
        }
        .share()

        // Table data.
        let tableData = sels
            .map({ sels -> [SectionModel] in
                let items = sels.enumerated().map { pair -> SectionItem in
                    let offset = pair.offset
                    let elem = pair.element
                    return SectionItem.ingredient(
                        row: 1 + offset,
                        viewModel: IngredientsItemCellViewModel(name: elem.ingredient.name,
                                                                priceText: format(price: elem.ingredient.price),
                                                                isContained: elem.isOn)
                    )
                }
                let header = [SectionItem.header(viewModel: IngredientsHeaderCellViewModel(image: self._image))]
                return [SectionModel(items: header + items)]
            })
            .asDriver(onErrorJustReturn: [])

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

        let title = _pizza
            .map({ $0.name == "scratch" ? "CREATE A PIZZA" : $0.name.uppercased() })
            .asDriver(onErrorJustReturn: "")

        let sum = (try? _pizza.value().ingredients.reduce(0.0, { $0 + $1.price })) ?? 0
        let cartText = "ADD TO CART ($\(sum))"
        return Output(title: title,
                      tableData: tableData,
                      cartText: Driver.just(cartText),
                      showAdded: input.addEvent.asDriver(onErrorJustReturn: ()))
    }

    private func _createSels() -> [Selected] {
        func isContained(_ ingredient: Domain.Ingredient) -> Bool {
            return (try? _pizza.value().ingredients.contains { $0.id == ingredient.id }) ?? false
        }

        let sels = _ingredients.map { ing -> Selected in
            (isContained(ing), ing)
        }
        return sels
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
