//
//  MenuTableViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain
import Resolver
import RxSwift
import RxRelay
import RxDataSources
import struct RxCocoa.Driver
import class UIKit.UIImage

final class MenuTableViewModel: ViewModelType {
    struct Input {
        let selected: Observable<Int>
        let scratch: Observable<Void>
    }

    struct Output {
        let tableData: Driver<[SectionModel]>
        let selection: Driver<Observable<Pizza>>
        let showAdded: Driver<Void>
    }

    @Injected private var _service: MenuUseCase
    private let _bag = DisposeBag()

    func transform(input: Input) -> Output {
        let cachedPizzas = BehaviorRelay(value: Pizzas.empty)
        _service.pizzas()
            .compactMap {
                switch $0 {
                case let .success(pizzas):
                    return pizzas as Pizzas?
                case .failure:
                    return nil
                }
            }
            .bind(to: cachedPizzas)
            .disposed(by: _bag)

        let viewModels = cachedPizzas
            .throttle(.milliseconds(400), latest: true, scheduler: MainScheduler.instance)
            .map { pizzas -> [MenuCellViewModel] in
                let basePrice = pizzas.basePrice
                let vms = pizzas.pizzas.map {
                    MenuCellViewModel(basePrice: basePrice, pizza: $0)
                }
                DLog("############## update pizza vms. #########")
                return vms
            }
            .share()

        let sectionModels = viewModels
            .map { [SectionModel(items: $0)] }

        let cartEvents = viewModels
            .map { vms in
                vms.enumerated().map { pair in
                    pair.element.tap
                        .map { _ in
                            pair.offset
                        }
                }
            }
            .flatMap {
                Observable.merge($0)
            }

        // Update cart on add events.
        let showAdded = Observable.combineLatest(cartEvents, cachedPizzas)
            .flatMapLatest { [service = _service] in
                service.addToCart(pizza: $0.1.pizzas[$0.0])
                    .catch { _ in Completable.never() }
                    .andThen(Observable.just(()))
            }

        // A pizza is selected.
        let selected = input.selected
            .map { index in
                cachedPizzas
                    .map { $0.pizzas[index] }
            }

        // Pizza from scratch is selected.
        let scratch = input.scratch
            .map { Observable.just(Pizza()) }

        let selection = Observable.merge(selected, scratch)

        return Output(tableData: sectionModels.asDriver(onErrorJustReturn: []),
                      selection: selection.asDriver(onErrorJustReturn: Observable<Pizza>.empty()),
                      showAdded: showAdded.asDriver(onErrorDriveWith: Driver<Void>.never())
        )
    }
}

extension MenuTableViewModel {
    struct SectionModel {
        var items: [MenuCellViewModel]
    }
}

extension MenuTableViewModel.SectionModel: AnimatableSectionModelType {
    typealias Item = MenuCellViewModel

    var identity: Int { 0 }

    init(original: MenuTableViewModel.SectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

extension MenuCellViewModel: IdentifiableType, Equatable {
    var identity: Int {
        nameText.hash
    }

    var unique: Int {
        image != nil ? 1 : 0
    }

    static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.identity == rhs.identity && lhs.unique == rhs.unique
    }
}
