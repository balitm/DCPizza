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

final class IngredientsViewModel: ObservableObject {
    /// Event to drive the buy footer of the controller.
    enum FooterEvent {
        case show, hide
    }

    // Input
    @Published var selected = -1
    @Published var isAppeared: Void = ()

    // Output
    @Published var headerData = IngredientsHeaderRowViewModel(image: nil)
    @Published var listData = [IngredientsItemRowViewModel]()
    @Published var title = ""
    @Published var cartText = ""
    @Published var showAdded = false
    var footerEvent: AnyPublisher<FooterEvent, Never> { _footerEvent.eraseToAnyPublisher() }

    private let _footerEvent = PassthroughRelay<FooterEvent>()
    private let _service: IngredientsUseCase
    private var _bag = Set<AnyCancellable>()
    private var _timerCancellable: AnyCancellable?

    deinit {
        DLog(">>> deinit: ", type(of: self))
    }

    init(service: IngredientsUseCase) {
        // DLog(">>> init: ", type(of: self))

        _service = service

        // Title.
        service.name()
            .assign(to: \.title, on: self)
            .store(in: &_bag)

        // Header row.
        service.pizza()
            .map({
                IngredientsHeaderRowViewModel(image: $0.image)
            })
            .assign(to: \.headerData, on: self)
            .store(in: &_bag)

        // Selections publisher.
        let selecteds = service.ingredients(selected:
            $selected
                .compactMap({
                    $0 >= 0 ? $0 : nil
                })
                .eraseToAnyPublisher()
        )

        // Items.
        selecteds
            .map({
                $0.enumerated().map({
                    IngredientsItemRowViewModel(name: $0.element.ingredient.name,
                                                priceText: format(price: $0.element.ingredient.price),
                                                isContained: $0.element.isOn,
                                                index: $0.offset)
                })
            })
            .assign(to: \.listData, on: self)
            .store(in: &_bag)

        // Selected ingredients.
        let selectedIngredients = CurrentValueSubject<[Ingredient], Never>([])
        selecteds
            .map({ sels -> [Ingredient] in
                sels.compactMap { $0.isOn ? $0.ingredient : nil }
            })
            .subscribe(selectedIngredients)
            .store(in: &_bag)

        // Cart text on the footer.
        selectedIngredients
            .map({ ings -> String in
                // TODO: sketch suggest to show only ingredient prices
                //       but + cart.basePrice would be better IMHO.
                let sum = ings.reduce(0.0, { $0 + $1.price })
                return "ADD TO CART (\(format(price: sum)))"
            })
            .assign(to: \.cartText, on: self)
            .store(in: &_bag)

        // Footer event publisher.
        let showReason = selectedIngredients
            .combineLatest($isAppeared.dropFirst())
            .map({ !$0.0.isEmpty })
            .eraseToAnyPublisher()
        _makeFooterPublisher(showReason)
    }

    func addToCart() {
        _service.addToCart()
            .catch({ error -> Empty<Void, Never> in
                DLog("recved error: ", error)
                return Empty<Void, Never>()
            })
            .map({ true })
            .assign(to: \.showAdded, on: self)
            .store(in: &_bag)
    }
}

private extension IngredientsViewModel {
    /// Create footer event publisher.
    func _makeFooterPublisher(_ publisher: AnyPublisher<Bool, Never>) {
        publisher
            .compactMap({ !$0 ? nil : FooterEvent.show })
            .subscribe(_footerEvent)
            .store(in: &_bag)

        publisher
            .sink(receiveValue: { [unowned self] _ in
                self._timerCancellable?.cancel()
                self._timerCancellable = Timer.publish(every: 3.0, on: .main, in: .default)
                    .autoconnect()
                    .first()
                    .map({ _ in
                        FooterEvent.hide
                    })
                    .subscribe(self._footerEvent)
            })
            .store(in: &_bag)
    }
}
