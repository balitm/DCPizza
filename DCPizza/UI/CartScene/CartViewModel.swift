//
//  CartViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain
import RxSwift
import RxSwiftExt
import RxDataSources
import struct RxCocoa.Driver

struct CartViewModel: ViewModelType {
    typealias DrinksData = (cart: UI.Cart, drinks: [Drink])

    struct SectionModel {
        var items: [SectionItem]
    }

    enum SectionItem {
        case padding(viewModel: PaddingCellViewModel)
        case item(viewModel: CartItemCellViewModel)
        case total(viewModel: CartTotalCellViewModel)
    }

    struct Input {
        let selected: Observable<Int>
        let checkout: Observable<Void>
    }

    struct Output {
        let tableData: Driver<[SectionModel]>
        let showSuccess: Driver<Void>
        let showDrinks: Driver<DrinksData>
    }

    var resultCart: Observable<UI.Cart> { cart.asObservable().skip(1) }
    let cart: BehaviorSubject<UI.Cart>
    private let _drinks: [Drink]
    private let _bag = DisposeBag()

    init(cart: UI.Cart, drinks: [Drink]) {
        self.cart = BehaviorSubject(value: cart)
        _drinks = drinks
    }

    func transform(input: Input) -> Output {
        let models = cart
            .map({ cart -> [SectionModel] in
                var items = [SectionItem.padding(viewModel: PaddingCellViewModel(height: 12))]
                let pizzas = cart.pizzas.enumerated().map {
                    SectionItem.item(viewModel: CartItemCellViewModel(pizza: $0.element,
                                                                      basePrice: cart.basePrice)
                    )
                }
                let drinks = cart.drinks.enumerated().map {
                    SectionItem.item(viewModel: CartItemCellViewModel(drink: $0.element))
                }
                items.append(contentsOf: pizzas)
                items.append(contentsOf: drinks)
                items.append(.padding(viewModel: PaddingCellViewModel(height: 24)))
                items.append(.total(viewModel: CartTotalCellViewModel(price: cart.totalPrice())))

//                DLog(">>> cart items:\n")
//                for i in 1 ..< items.count - 2 {
//                    print("#", i, ">>>", items[i].identity, "-", items[i].unique)
//                }
                return [SectionModel(items: items)]
            })
            // .debug(trimOutput: true)

        input.selected
            .withLatestFrom(cart) { (index: $0, cart: $1) }
            .filterMap({ pair -> FilterMap<UI.Cart> in
                assert(pair.index >= 1)
                let index = pair.index - 1

                DLog(">>> index: ", index)
                var newCart = pair.cart
                newCart.remove(at: index)
                DLog(">>> pizzas in cart: ", newCart.pizzas.count)
                return .map(newCart)
            })
            .bind(to: cart)
            .disposed(by: _bag)

        let checkout = input.checkout
            .withLatestFrom(cart)
            .flatMap({ cart -> Observable<UI.Cart> in
                let useCase = RepositoryNetworkUseCaseProvider().makeNetworkUseCase()
                return useCase.checkout(cart: cart.asDomain())
                    .map({ cart })
            })
            .share()

        checkout
            .map({
                var newCart = $0
                newCart.empty()
                return newCart
            })
            .bind(to: cart)
            .disposed(by: _bag)

        let showDrinks = cart
            .map({ [drinks = _drinks] in ($0, drinks) })
            .asDriver(onErrorDriveWith: Driver<DrinksData>.never())

        return Output(
            tableData: models.asDriver(onErrorJustReturn: []),
            showSuccess: checkout
                .map({ _ in () })
                .asDriver(onErrorJustReturn: ()),
            showDrinks: showDrinks
        )
    }
}

extension CartViewModel.SectionModel: AnimatableSectionModelType {
    var identity: Int { return 0 }

    typealias Item = CartViewModel.SectionItem

    init(original: CartViewModel.SectionModel, items: [CartViewModel.SectionItem]) {
        self = original
        self.items = items
    }
}

extension CartViewModel.SectionItem: IdentifiableType, Equatable {
    var identity: Int {
        switch self {
        case let .padding(viewModel): return 1000 + Int(viewModel.height)
        case let .item(viewModel): return viewModel.id
        case .total: return 2000
        }
    }

    var unique: Double {
        switch self {
        case let .total(viewModel):
            return viewModel.price
        default:
            return 0
        }
    }

    static func ==(lhs: CartViewModel.SectionItem, rhs: CartViewModel.SectionItem) -> Bool {
        return lhs.identity == rhs.identity && lhs.unique == rhs.unique
    }
}
