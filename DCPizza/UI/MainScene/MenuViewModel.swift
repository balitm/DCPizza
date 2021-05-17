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

final class MenuViewModel: ViewModelType {
    typealias Item = MenuCellViewModel

    struct Input {
        let selected: AnyPublisher<Int, Never>
        let shown: AnyPublisher<Item, Never>
        let scratch: AnyPublisher<Void, Never>
    }

    struct Output {
        let tableData: AnyPublisher<[MenuCellViewModel], Never>
        let selection: AnyPublisher<AnyPublisher<Pizza, Never>, Never>
        let showAdded: AnyPublisher<Void, Never>
    }

    private let _service: MenuUseCase
    private var _bag = Set<AnyCancellable>()

    init(service: MenuUseCase) {
        _service = service
    }

    func transform(input: Input) -> Output {
        let cachedPizzas = CurrentValueRelay(Pizzas.empty)
        _service.pizzas()
            .compactMap {
                guard $0.error == nil else {
                    // Handle error.
                    return nil
                }
                return $0.pizzas
            }
            .subscribe(cachedPizzas)
            .store(in: &_bag)

        let viewModels = cachedPizzas
            .throttle(for: 0.4, scheduler: RunLoop.current, latest: true)
            .map { pizzas -> [MenuCellViewModel] in
                let basePrice = pizzas.basePrice
                let vms = pizzas.pizzas.enumerated().map {
                    MenuCellViewModel(basePrice: basePrice, pizza: $0.element, offset: $0.offset)
                }
                DLog("############## update pizza vms. #########")
                return vms
            }
            .share()

        // Fetch a pizza image if needed.
        input.shown
            .compactMap {
                $0.shouldFetchImage
                    ? ImageInfo(url: $0.url!, offset: $0.offset)
                    : nil
            }
            .subscribe(_service.imageInfo)

        // Buy tapped.
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
                Publishers.MergeMany($0)
            }

        // Update cart on add events.
        let showAdded = cartEvents
            .flatMap { index in
                cachedPizzas
                    .first()
                    .map { (index, $0) }
            }
            .flatMap { [service = _service] index, pizzas in
                service.addToCart(pizza: pizzas.pizzas[index])
                    .catch { _ in Empty<Void, Never>() }
            }

        // A pizza is selected.
        let selected = input.selected
            .map { index in
                cachedPizzas
                    .map { $0.pizzas[index] }
                    .eraseToAnyPublisher()
            }

        // Pizza from scratch is selected.
        let scratch = input.scratch
            .map { Just(Pizza()).eraseToAnyPublisher() }

        let selection = selected.merge(with: scratch)

        return Output(tableData: viewModels.eraseToAnyPublisher(),
                      selection: selection.eraseToAnyPublisher(),
                      showAdded: showAdded.eraseToAnyPublisher()
        )
    }
}
