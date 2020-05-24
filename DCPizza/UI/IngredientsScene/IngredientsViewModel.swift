//
//  IngredientsTableViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/19/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain
import Combine
import class UIKit.UIImage

final class IngredientsViewModel: ViewModelType {
    /// Ingredient with selectcion flag.
    typealias Selected = (isOn: Bool, ingredient: Ingredient)

    /// Event to drive the buy footer of the controller.
    enum FooterEvent {
        case show, hide
    }

    struct Input {
        let selected: AnyPublisher<Int, Never>
        let addEvent: AnyPublisher<Void, Never>
    }

    struct Output {
        let title: AnyPublisher<String?, Never>
        let tableData: AnyPublisher<[Item], Never>
        let cartText: AnyPublisher<String?, Never>
        let showAdded: AnyPublisher<Void, Never>
        let footerEvent: Publishers.MakeConnectable<AnyPublisher<FooterEvent, Never>>
    }

    private let _service: IngredientsUseCase
    private var _bag = Set<AnyCancellable>()
    private var _timerCancellable: AnyCancellable?

    init(service: IngredientsUseCase) {
        _service = service
    }

    deinit {
        DLog(">>> deinit: ", type(of: self))
    }

    func transform(input: Input) -> Output {
        // Selections publisher.
        let selecteds = _service.ingredients(selected:
            input.selected
                .compactMap({ $0 >= 1 ? $0 - 1 : nil })
                .eraseToAnyPublisher()
        )

        // Table data source.
        let tableData = selecteds
            .map({ [image = _service.image()] sels -> [Item] in
                let items = sels.map { elem -> Item in
                    Item.ingredient(
                        viewModel: IngredientsItemCellViewModel(name: elem.ingredient.name,
                                                                priceText: format(price: elem.ingredient.price),
                                                                isContained: elem.isOn)
                    )
                }
                let header = [Item.header(viewModel: IngredientsHeaderCellViewModel(image: image))]
                return header + items
            })

        // Selected ingredients.
        let selectedIngredients = CurrentValueSubject<[Ingredient], Never>([])
        selecteds
            .map({ sels -> [Ingredient] in
                sels.compactMap { $0.isOn ? $0.ingredient : nil }
            })
            .subscribe(AnySubscriber(selectedIngredients))

        // Add pizza to cart.
        input.addEvent
            .flatMap({ [service = _service] in
                service.addToCart()
                    .catch({ error -> Empty<Void, Never> in
                        DLog("recved error: ", error)
                        return Empty<Void, Never>()
                    })
            })
            .sink {}
            .store(in: &_bag)

        let cartText = selectedIngredients
            .map({ ings -> String? in
                // TODO: sketch suggest to show only ingredient prices
                //       but + cart.basePrice would be better IMHO.
                let sum = ings.reduce(0.0, { $0 + $1.price })
                return "ADD TO CART (\(format(price: sum)))"
            })

        let footerEvent = _makeFooterPublisher(selectedIngredients.eraseToAnyPublisher())
            .makeConnectable()

        return Output(title: _service.name().map({ $0 as String? }).eraseToAnyPublisher(),
                      tableData: tableData.eraseToAnyPublisher(),
                      cartText: cartText.eraseToAnyPublisher(),
                      showAdded: input.addEvent,
                      footerEvent: footerEvent
        )
    }
}

private extension IngredientsViewModel {
    /// Create footer event publisher.
    func _makeFooterPublisher(_ publisher: AnyPublisher<[Ingredient], Never>) -> AnyPublisher<FooterEvent, Never> {
        let footerEvent = CurrentValueRelay(FooterEvent.hide)

        publisher
            .compactMap({ $0.isEmpty ? nil : FooterEvent.show })
            .subscribe(AnySubscriber(footerEvent))

        publisher
            .sink(receiveValue: { [unowned self] _ in
                self._timerCancellable?.cancel()
                self._timerCancellable = Timer.publish(every: 3.0, on: .main, in: .default)
                    .autoconnect()
                    .first()
                    .map({ _ in FooterEvent.hide })
                    .sink(receiveValue: {
                        footerEvent.send($0)
                    })
            })
            .store(in: &_bag)

        return footerEvent.eraseToAnyPublisher()
    }
}

// MARK: - Table item types

extension IngredientsViewModel {
    enum Item: Hashable {
        case header(viewModel: IngredientsHeaderCellViewModel)
        case ingredient(viewModel: IngredientsItemCellViewModel)
    }
}
