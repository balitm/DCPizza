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
import struct SwiftUI.Image

final class MenuListViewModel: ObservableObject {
    // Input
    @Published var selected = -1
    @Published var scratch: Void = ()

    // Output
    @Published var tableData = [MenuRowViewModel]()
//    @Published var selection: AnyPublisher<AnyPublisher<Pizza, Never>, Never>
//    @Published var showAdded: AnyPublisher<Void, Never>

    private var _bag = Set<AnyCancellable>()

    init(service: MenuUseCase) {
        let cachedPizzas = CurrentValueRelay(Pizzas.empty)

        service.pizzas()
            .compactMap({
                switch $0 {
                case let .success(pizzas):
                    return pizzas as Pizzas?
                case .failure:
                    return nil
                }
            })
            .subscribe(cachedPizzas)
            .store(in: &_bag)

        cachedPizzas
            .throttle(for: 0.4, scheduler: RunLoop.current, latest: true)
            .map({ pizzas -> [MenuRowViewModel] in
                let basePrice = pizzas.basePrice
                let vms = pizzas.pizzas.map {
                    MenuRowViewModel(basePrice: basePrice, pizza: $0)
                }
                DLog("############## update pizza vms. #########")
                return vms
            })
            .assign(to: \.tableData, on: self)
            .store(in: &_bag)
    }

//    func transform(input: Input) -> Output {
//
//        let viewModels = cachedPizzas
//            .throttle(for: 0.4, scheduler: RunLoop.current, latest: true)
//            .map({ pizzas -> [MenuRowViewModel] in
//                let basePrice = pizzas.basePrice
//                let vms = pizzas.pizzas.map {
//                    MenuRowViewModel(basePrice: basePrice, pizza: $0)
//                }
//                DLog("############## update pizza vms. #########")
//                return vms
//            })
//            .share()
//
//        let cartEvents = viewModels
//            .map({ vms in
//                vms.enumerated().map({ pair in
//                    pair.element.tap
//                        .map({ _ in
//                            pair.offset
//                        })
//                })
//            })
//            .flatMap({
//                Publishers.MergeMany($0)
//            })
//
//        // Update cart on add events.
//        let showAdded = cartEvents.combineLatest(cachedPizzas)
//            .flatMap({ [service = _service] in
//                service.addToCart(pizza: $0.1.pizzas[$0.0])
//                    .catch({ _ in Empty<Void, Never>() })
//            })
//
//        // A pizza is selected.
//        let selected = input.selected
//            .map({ index in
//                cachedPizzas
//                    .map({ $0.pizzas[index] })
//                    .eraseToAnyPublisher()
//            })
//
//        // Pizza from scratch is selected.
//        let scratch = input.scratch
//            .map({ Just(Pizza()).eraseToAnyPublisher() })
//
//        let selection = selected.merge(with: scratch)
//
//        return Output(tableData: viewModels.eraseToAnyPublisher(),
//                      selection: selection.eraseToAnyPublisher(),
//                      showAdded: showAdded.eraseToAnyPublisher()
//        )
//    }
}
