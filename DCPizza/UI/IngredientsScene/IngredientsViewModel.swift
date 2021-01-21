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
import RxRelay
import RxDataSources
import struct RxCocoa.Driver
import class UIKit.UIImage

struct IngredientsViewModel: ViewModelType {
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

    private let _service: IngredientsUseCase
    private let _bag = DisposeBag()
    private var _timerCancellable: Disposable?

    init(service: IngredientsUseCase) {
        _service = service
    }

    func transform(input: Input) -> Output {
        // Selections publisher.
        let selecteds = _service.ingredients(selected:
            input.selected
                .compactMap { $0 >= 1 ? $0 - 1 : nil }
        )
        .share(replay: 1)

        // Table data source.
        let tableData = Observable.combineLatest(selecteds, _service.pizza())
            .map { (pair: (sels: [IngredientSelection], pizza: Pizza)) -> [SectionModel] in
                let items = pair.sels.enumerated().map {
                    Item.ingredient(
                        row: $0.offset + 1,
                        viewModel: IngredientsItemCellViewModel(name: $0.element.ingredient.name,
                                                                priceText: format(price: $0.element.ingredient.price),
                                                                isContained: $0.element.isOn)
                    )
                }

                let header = [Item.header(viewModel: IngredientsHeaderCellViewModel(image: pair.pizza.image))]
                return [SectionModel(items: header + items)]
            }
            .asDriver(onErrorJustReturn: [])

        // Selected ingredients.
        let selectedIngredients = BehaviorSubject<[Ingredient]>(value: [])
        selecteds
            .map { sels -> [Ingredient] in
                sels.compactMap { $0.isOn ? $0.ingredient : nil }
            }
            .bind(to: selectedIngredients)
            .disposed(by: _bag)

        // Add pizza to cart.
        input.addEvent
            .flatMap { [service = _service] in
                service.addToCart()
                    .catch { error in
                        DLog("recved error: ", error)
                        return Completable.empty()
                    }
            }
            .subscribe()
            .disposed(by: _bag)

        let cartText = selectedIngredients
            .map { ings -> String in
                // TODO: sketch suggest to show only ingredient prices
                //       but + cart.basePrice would be better IMHO.
                let sum = ings.reduce(0.0) { $0 + $1.price }
                return "ADD TO CART (\(format(price: sum)))"
            }
            .asDriver(onErrorJustReturn: "")

        let footerEvent = _makeFooterObservable(selectedIngredients.map { _ in () })
            .asDriver(onErrorJustReturn: .hide)

        return Output(title: _service.name().asDriver(onErrorJustReturn: ""),
                      tableData: tableData,
                      cartText: cartText,
                      showAdded: input.addEvent.asDriver(onErrorJustReturn: ()),
                      footerEvent: footerEvent
        )
    }
}

private extension IngredientsViewModel {
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

// MARK: - Table item types

extension IngredientsViewModel {
    struct SectionModel {
        var items: [Item]
    }

    enum Item {
        case header(viewModel: IngredientsHeaderCellViewModel)
        case ingredient(row: Int, viewModel: IngredientsItemCellViewModel)
    }
}

extension IngredientsViewModel.SectionModel: AnimatableSectionModelType {
    typealias Item = IngredientsViewModel.Item

    var identity: Int { 0 }

    init(original: IngredientsViewModel.SectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

extension IngredientsViewModel.Item: IdentifiableType, Equatable {
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
        case let .header(viewModel):
            return viewModel.image == nil
        case let .ingredient(_, viewModel):
            return viewModel.isContained
        }
    }

    static func ==(lhs: IngredientsViewModel.Item, rhs: IngredientsViewModel.Item) -> Bool {
        // if (lhs == .header) {
        //     DLog(lhs)
        // }
        lhs.identity == rhs.identity && lhs.unique == rhs.unique
    }
}
