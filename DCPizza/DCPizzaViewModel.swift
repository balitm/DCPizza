//
//  DCPizzaViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 11/2/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Combine
import Domain
import Resolver

final class DCPizzaViewModel {
    private var _bag = Set<AnyCancellable>()
    @LazyInjected private var _service: SaveUseCase

    func saveCart() {
        _service.saveCart()
            .catch { _ in Empty<Void, Never>() }
            .sink {}
            .store(in: &_bag)
    }
}
