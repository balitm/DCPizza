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
import Resolver

struct CartViewModel: ViewModelType {
    struct SectionModel {
        var items: [Item]
    }

    enum Item {
        case padding(viewModel: PaddingCellViewModel)
        case item(id: Int, viewModel: CartItemCellViewModel)
        case total(viewModel: CartTotalCellViewModel)
    }

    struct Input {
        let selected: Observable<Int>
        let checkout: Observable<Void>
    }

    struct Output {
        let tableData: Driver<[SectionModel]>
        let showSuccess: Driver<Void>
        let canCheckout: Driver<Bool>
    }

    @Injected private var _service: CartUseCase
    private let _bag = DisposeBag()

    func transform(input: Input) -> Output {
        let models = Observable.zip(_service.items(), _service.total())
            .map { (pair: (items: [CartItem], total: Double)) -> [SectionModel] in
                var items = [Item.padding(viewModel: PaddingCellViewModel(height: 12))]
                items.append(
                    contentsOf: pair.items.map { Item.item(id: $0.id, viewModel: CartItemCellViewModel(item: $0)) }
                )
                items.append(.padding(viewModel: PaddingCellViewModel(height: 24)))
                items.append(.total(viewModel: CartTotalCellViewModel(price: pair.total)))
                return [SectionModel(items: items)]
            }
        // .debug(trimOutput: true)

        input.selected
            .flatMap { [service = _service] idx -> Completable in
                assert(idx > 0)
                return service.remove(at: idx - 1)
                    .catch { _ in Completable.empty() }
            }
            .subscribe()
            .disposed(by: _bag)

        let checkout = input.checkout
            .flatMap { [service = _service] in
                service.checkout()
                    .catch { _ in Completable.empty() }
                    .andThen(Observable.just(()))
            }

        let canCheckout = _service.items()
            .map { !$0.isEmpty }
            .asDriver(onErrorJustReturn: false)

        return Output(
            tableData: models.asDriver(onErrorJustReturn: []),
            showSuccess: checkout
                .asDriver(onErrorJustReturn: ()),
            canCheckout: canCheckout
        )
    }
}

extension CartViewModel.SectionModel: AnimatableSectionModelType {
    var identity: Int { 0 }

    typealias Item = CartViewModel.Item

    init(original: CartViewModel.SectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

extension CartViewModel.Item: IdentifiableType, Equatable {
    var identity: Int {
        switch self {
        case let .padding(viewModel): return 1000 + Int(viewModel.height)
        case let .item(id, _): return id
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

    static func ==(lhs: CartViewModel.Item, rhs: CartViewModel.Item) -> Bool {
        lhs.identity == rhs.identity && lhs.unique == rhs.unique
    }
}
