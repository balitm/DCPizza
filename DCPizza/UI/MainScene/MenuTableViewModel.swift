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
    typealias Item = MenuCellViewModel

    struct Input {
        let selected: AnyPublisher<Int, Never>
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
                switch $0 {
                case let .success(pizzas):
                    return pizzas as Pizzas?
                case .failure:
                    return nil
                }
            }
            .subscribe(cachedPizzas)
            .store(in: &_bag)

        let viewModels = cachedPizzas
            .throttle(for: 0.4, scheduler: RunLoop.current, latest: true)
            .map { pizzas -> [MenuCellViewModel] in
                let basePrice = pizzas.basePrice
                let vms = pizzas.pizzas.map {
                    MenuCellViewModel(basePrice: basePrice, pizza: $0)
                }
                DLog("############## update pizza vms. #########")
                return vms
            }
            .share()

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
        let showAdded = cartEvents.combineLatest(cachedPizzas)
            .flatMap { [service = _service] in
                service.addToCart(pizza: $0.1.pizzas[$0.0])
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
