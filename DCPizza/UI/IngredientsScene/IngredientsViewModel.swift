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
    private let _pizza: Pizza
    private let _image: UIImage?
    private var _bag = Set<AnyCancellable>()
    private var _timerCancellable: AnyCancellable?

    init(service: IngredientsUseCase, pizza: Pizza, image: UIImage?) {
        _pizza = pizza
        _image = image
        _service = service
    }

    deinit {
        DLog(">>> deinit: ", type(of: self))
    }

    func transform(input: Input) -> Output {
        let ingredients = CurrentValueRelay([Ingredient]())
        _service.ingredients()
            .subscribe(AnySubscriber(ingredients))

        // Create selections publisher.
        let selecteds = _makeSelectionPublisher(
            ingredients.eraseToAnyPublisher(),
            input.selected
                .compactMap({ $0 >= 1 ? $0 - 1 : nil })
                .eraseToAnyPublisher()
        )

        // Table data source.
        let tableData = selecteds
            .map({ sels -> [Item] in
                let items = sels.map { elem -> Item in
                    Item.ingredient(
                        viewModel: IngredientsItemCellViewModel(name: elem.ingredient.name,
                                                                priceText: format(price: elem.ingredient.price),
                                                                isContained: elem.isOn)
                    )
                }
                let header = [Item.header(viewModel: IngredientsHeaderCellViewModel(image: self._image))]
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
            .flatMap({
                selectedIngredients
                    .first()
            })
            .map({ [pizza = _pizza] in
                Pizza(copy: pizza, with: $0)
            })
            .flatMap({ [service = _service] in
                service.add(pizza: $0)
                    .catch({ error -> Empty<Void, Never> in
                        DLog("recved error: ", error)
                        return Empty<Void, Never>()
                    })
            })
            .sink {}
            .store(in: &_bag)

        // Title for the scene.
        let title = Just(_pizza)
            .map({ pizza -> String? in
                pizza.ingredients.isEmpty ? "CREATE A PIZZA" : pizza.name.uppercased()
            })

        let cartText = selectedIngredients
            .map({ ings -> String? in
                // TODO: sketch suggest to show only ingredient prices
                //       but + cart.basePrice would be better IMHO.
                let sum = ings.reduce(0.0, { $0 + $1.price })
                return "ADD TO CART (\(format(price: sum)))"
            })

        let footerEvent = _makeFooterPublisher(selectedIngredients.map { _ in () }.eraseToAnyPublisher())
            .makeConnectable()

        return Output(title: title.eraseToAnyPublisher(),
                      tableData: tableData.eraseToAnyPublisher(),
                      cartText: cartText.eraseToAnyPublisher(),
                      showAdded: input.addEvent,
                      footerEvent: footerEvent
        )
    }
}

private extension IngredientsViewModel {
    /// Create array of Ingredients with selectcion flag.
    func _createSelecteds(_ ingredients: [Ingredient]) -> [Selected] {
        func isContained(_ ingredient: Domain.Ingredient) -> Bool {
            _pizza.ingredients.contains { $0.id == ingredient.id }
        }

        let sels = ingredients.map { ing -> Selected in
            (isContained(ing), ing)
        }
        return sels
    }

    /// Create selections publisher.
    func _makeSelectionPublisher(_ ingredients: AnyPublisher<[Ingredient], Never>,
                                 _ selected: AnyPublisher<Int, Never>) -> CurrentValueSubject<[Selected], Never> {
        let subject = CurrentValueSubject<[Selected], Never>([])
        ingredients
            .map({ [unowned self] in
                self._createSelecteds($0)
            })
            .subscribe(AnySubscriber(subject))

        selected
            .flatMap({ idx in
                subject
                    .first()
                    .map({ (idx: idx, selecteds: $0) })
            })
            .map({
                var ings = $0.selecteds
                let item = $0.selecteds[$0.idx]
                ings[$0.idx] = (!item.isOn, item.ingredient)
                return ings
            })
            .subscribe(AnySubscriber(subject))

        return subject
    }

    /// Create footer event publisher.
    func _makeFooterPublisher(_ publisher: AnyPublisher<Void, Never>) -> AnyPublisher<FooterEvent, Never> {
        let footerEvent = CurrentValueRelay(FooterEvent.hide)

        publisher
            .map({ FooterEvent.show })
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

// MARK: - Table model types

extension IngredientsViewModel {
    enum Item: Hashable {
        case header(viewModel: IngredientsHeaderCellViewModel)
        case ingredient(viewModel: IngredientsItemCellViewModel)
    }
}
