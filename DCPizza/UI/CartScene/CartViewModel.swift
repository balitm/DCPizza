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
import RxDataSources
import struct RxCocoa.Driver

struct CartViewModel: ViewModelType {
    struct SectionModel {
        var items: [SectionItem]
    }

    enum SectionItem {
        case padding(row: Int, viewModel: PaddingCellViewModel)
        case item(row: Int, viewModel: CartItemCellViewModel)
        case total(row: Int, viewModel: CartTotalCellViewModel)
    }

    struct Input {
    }

    struct Output {
        let tableData: Driver<[SectionModel]>
    }

    var cart: Observable<Cart> { _cart.asObservable().skip(1) }
    private let _cart: BehaviorSubject<Cart>
    private let _bag = DisposeBag()

    init(cart: Cart) {
        _cart = BehaviorSubject(value: cart)
    }

    func transform(input: Input) -> Output {
        let models = _cart
            .map({ cart -> [SectionModel] in
                var items = [SectionItem.padding(row: 0, viewModel: PaddingCellViewModel(height: 12))]
                var offset = 1
                let elems = cart.pizzas.enumerated().map {
                    SectionItem.item(row: offset + $0.offset,
                                     viewModel: CartItemCellViewModel(name: $0.element.name,
                                                                      priceText: "$0"))}
                items.append(contentsOf: elems)
                offset += elems.count
                items.append(.padding(row: offset, viewModel: PaddingCellViewModel(height: 24)))
                offset += 1
                items.append(.total(row: offset, viewModel: CartTotalCellViewModel(price: 0)))
//                elems = cart.drinks.enumerated().map {
//                    SectionItem.item(row: offset + $0.offset,
//                                     viewModel: CartItemCellViewModel(name: $0.element.name,
//                                                                      priceText: "$0"))}
                return [SectionModel(items: items)]
            })

        return Output(
            tableData: models.asDriver(onErrorJustReturn: [])
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
        case let .padding(row, _): return row
        case let .item(row, _): return row
        case let .total(row, _): return row
        }
    }

    var unique: Double {
        switch self {
        case let .total(_, viewModel):
            return viewModel.price
        default:
            return 0
        }
    }

    static func ==(lhs: CartViewModel.SectionItem, rhs: CartViewModel.SectionItem) -> Bool {
        return lhs.identity == rhs.identity && lhs.unique == rhs.unique
    }
}
