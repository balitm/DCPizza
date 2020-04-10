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
import RxSwiftExt
import RxRelay
import RxDataSources
import struct RxCocoa.Driver
import class UIKit.UIImage

struct IngredientsViewModel: ViewModelType {
    /// Ingredient with selectcion flag.
    typealias Selected = (isOn: Bool, ingredient: Ingredient)

    /// Event to drive the buy footer of the controller.
    enum FooterEvent {
        case show, hide
    }

    struct Input {
        let selected: Observable<Int>
        let addEvent: Observable<Void>
    }

    struct Output {
        let title: Driver<String>
        let tableData: Driver<[SectionModel]>
        let cartText: Driver<String>
        let showAdded: Driver<Void>
        let footerEvent: Driver<FooterEvent>
    }

    var resultCart: Observable<UI.Cart> { cart.asObservable().skip(1) }
    let cart: BehaviorSubject<UI.Cart>
    private let _pizza: Pizza
    private let _image: UIImage?
    private let _ingredients: [Ingredient]
    private let _bag = DisposeBag()

    init(pizza: Pizza, image: UIImage?, ingredients: [Ingredient], cart: UI.Cart) {
        _pizza = pizza
        _image = image
        _ingredients = ingredients
        self.cart = BehaviorSubject(value: cart)
    }

    func transform(input: Input) -> Output {
        // Create selections observable.
        let selecteds = _makeSelectionObservable(
            input.selected
                .filterMap({ $0 >= 1 ? .map($0 - 1) : .ignore })
        )
        .share(replay: 1)

        // Table data.
        let tableData = selecteds
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

        // Selected ingredients.
        let selectedIngredients = selecteds
            .map { $0.compactMap { $0.isOn ? $0.ingredient : nil } }
            .skipWhile({ $0.isEmpty })
            .share(replay: 1)

        // Add pizza to cart.
        input.addEvent
            .withLatestFrom(Observable.combineLatest(cart, selectedIngredients)) { (cart: $1.0, ingredients: $1.1) }
            .map({
                var newCart = $0.cart
                let pizza = Pizza(copy: self._pizza, with: $0.ingredients)
                newCart.add(pizza: pizza)
                return newCart
            })
            .bind(to: cart)
            .disposed(by: _bag)

        // Title for the scene.
        let title = Driver.just(_pizza)
            .map({ $0.ingredients.isEmpty ? "CREATE A PIZZA" : $0.name.uppercased() })
            .asDriver(onErrorJustReturn: "")

        let cartText = selectedIngredients
            .map({ ings -> String in
                // TODO: sketch suggest to show only ingredient prices
                //       but + cart.basePrice would be better IMHO.
                let sum = ings.reduce(0.0, { $0 + $1.price })
                return "ADD TO CART (\(format(price: sum)))"
            })
            .asDriver(onErrorJustReturn: "")

        let footerEvent = _makeFooterObservable(selectedIngredients.map { _ in () })
            .asDriver(onErrorJustReturn: .hide)

        return Output(title: title,
                      tableData: tableData,
                      cartText: cartText,
                      showAdded: input.addEvent.asDriver(onErrorJustReturn: ()),
                      footerEvent: footerEvent
        )
    }
}

private extension IngredientsViewModel {
    /// Create array of Ingredients with selectcion flag.
    func _createSelecteds() -> [Selected] {
        func isContained(_ ingredient: Domain.Ingredient) -> Bool {
            _pizza.ingredients.contains { $0.id == ingredient.id }
        }

        let sels = _ingredients.map { ing -> Selected in
            (isContained(ing), ing)
        }
        return sels
    }

    /// Create selections observable.
    func _makeSelectionObservable(_ selected: Observable<Int>) -> Observable<[Selected]> {
        let items = _createSelecteds()

        return Observable<[Selected]>.create { observer in
            observer.onNext(items)
            var ings = items

            let disposable = selected
                .map({ idx -> [Selected] in
                    let item = ings[idx]
                    ings[idx] = (!item.isOn, item.ingredient)
                    return ings
                })
                .do(onNext: { observer.onNext($0) })
                .subscribe()

            return disposable
        }
    }

    /// Create footer event observable.
    func _makeFooterObservable(_ observable: Observable<Void>) -> Observable<FooterEvent> {
        Observable<FooterEvent>.create { [unowned bag = _bag] observer in
            var timerBag = DisposeBag()
            let footerEvent = PublishRelay<FooterEvent>()

            let disposable = footerEvent
                .bind(to: observer)

            observable
                .subscribe(onNext: { _ in
                    footerEvent.accept(.show)

                    timerBag = DisposeBag()
                    Observable<Int>.timer(.seconds(3), scheduler: MainScheduler.instance)
                        .map { _ in FooterEvent.hide }
                        .bind(to: footerEvent)
                        .disposed(by: timerBag)
                })
                .disposed(by: bag)

            return disposable
        }
    }
}

// MARK: - Table model types

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

    var identity: Int { 0 }

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
        lhs.identity == rhs.identity && lhs.unique == rhs.unique
    }
}
