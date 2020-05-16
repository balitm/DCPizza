//
//  MenuTableViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain
import Combine
import class UIKit.UIImage

final class MenuTableViewModel: ViewModelType {
    typealias Selected = (index: Int, image: UIImage?)
    typealias Selection = (
        pizza: Pizza,
        image: UIImage?
    )

    struct Input {
        let selected: AnyPublisher<Selected, Never>
        let scratch: AnyPublisher<Void, Never>
        let saveCart: AnyPublisher<Void, Never>
    }

    struct Output {
        let tableData: AnyPublisher<[MenuCellViewModel], Never>
        let selection: AnyPublisher<Selection, Never>
        let showAdded: AnyPublisher<Void, Never>
    }

    private let _menuUseCase: MenuUseCase
    private var _bag = Set<AnyCancellable>()

    init(menuUseCase: MenuUseCase) {
        _menuUseCase = menuUseCase
    }

    func transform(input: Input) -> Output {
        let cachedPizzas = CurrentValueRelay(Pizzas.empty)
        _menuUseCase.pizzas()
            .compactMap({
                switch $0 {
                case let .success(pizzas):
                    return pizzas as Pizzas?
                case .failure:
                    return nil
                }
            })
            .subscribe(AnySubscriber(cachedPizzas))

        let viewModels = cachedPizzas
            .map({ pizzas -> [MenuCellViewModel] in
                let basePrice = pizzas.basePrice
                let vms = pizzas.pizzas.map {
                    MenuCellViewModel(basePrice: basePrice, pizza: $0)
                }
                return vms
            })
            .print()
            .share()

        let cartEvents = viewModels
            .map({ vms in
                vms.enumerated().map({ pair in
                    pair.element.tap
                        .map({ _ in
                            pair.offset
                        })
                })
            })
            .flatMap({
                Publishers.MergeMany($0)
                    .handleEvents(receiveOutput: {
                        DLog("recved pair: ", $0)
                    }, receiveCompletion: {
                        DLog("completion: ", $0)
                    }, receiveCancel: {
                        DLog("cancel")
                    })
            })
            .share()

        // Update cart on add events.
        cartEvents.combineLatest(cachedPizzas)
            .flatMap({ [menuUseCase = _menuUseCase] in
                menuUseCase.add(pizza: $0.1.pizzas[$0.0])
                    .catch({ _ in Empty<Void, Never>() })
            })
            .sink {}
            .store(in: &_bag)

        // A pizza is selected.
        let selected = input.selected
            .flatMap({ selected in
                cachedPizzas
                    .first()
                    .map({
                        (pizzas: $0.pizzas, selected: selected)
                    })
            })
            .map({ t -> Selection in
                let pizza = t.pizzas[t.selected.index]
                let image = t.selected.image
                return (pizza, image)
            })

        // Pizza from scratch is selected.
        let scratch = input.scratch
            .flatMap({
                cachedPizzas
                    .first()
            })
            .map({ (t: Pizzas) -> Selection in
                let pizza = Pizza()
                return (pizza, nil)
            })

        let selection = Publishers.Merge(selected, scratch)

        input.saveCart
            .flatMap({ [menuUseCase = _menuUseCase] in
                menuUseCase.saveCart()
                    .catch({ _ in Empty<Void, Never>() })
            })
            .sink {}
            .store(in: &_bag)

        let showAdded = cartEvents.map({ _ in () })

        return Output(tableData: viewModels.eraseToAnyPublisher(),
                      selection: selection.eraseToAnyPublisher(),
                      showAdded: showAdded.eraseToAnyPublisher()
        )
    }
}
