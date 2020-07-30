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
    // Output
    @Published var listData = [MenuRowViewModel]()
    @Published var showAdded = false

    private let _cachedPizzas = CurrentValueRelay(Pizzas.empty)
    private var _bag = Set<AnyCancellable>()

    init(service: MenuUseCase) {
        DLog(">>> init: ", type(of: self))

        // Cache pizzas.
        service.pizzas()
            .compactMap({
                switch $0 {
                case let .success(pizzas):
                    return pizzas as Pizzas?
                case .failure:
                    return nil
                }
            })
            .subscribe(_cachedPizzas)
            .store(in: &_bag)

        // Fill up listData.
        _cachedPizzas
            .throttle(for: 0.4, scheduler: RunLoop.current, latest: true)
            .map({ pizzas -> [MenuRowViewModel] in
                let basePrice = pizzas.basePrice
                let vms = pizzas.pizzas.enumerated().map {
                    MenuRowViewModel(index: $0.offset, basePrice: basePrice, pizza: $0.element)
                }
                DLog("############## update pizza vms. #########")
                return vms
            })
            .assign(to: \.listData, on: self)
            .store(in: &_bag)

        let cartEvents = $listData
            .map({ vms in
                vms.map({
                    $0.$tap
                        .dropFirst()
                })
            })
            .flatMap({
                Publishers.MergeMany($0)
            })

        // Update cart on add events.
        cartEvents.combineLatest(_cachedPizzas)
            .flatMap({ (pair: (index: Int, pizzas: Pizzas)) in
                service.addToCart(pizza: pair.pizzas.pizzas[pair.index])
                    .catch({ _ in Empty<Void, Never>() })
                    .map({ true })
            })
            .assign(to: \.showAdded, on: self)
            .store(in: &_bag)
    }

    func pizza(at index: Int) -> AnyPublisher<Pizza, Never> {
        _cachedPizzas
            .map({ $0.pizzas[index] })
            .eraseToAnyPublisher()
    }
}
