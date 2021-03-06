//
//  RepositoryUseCaseProvider.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Combine

public struct RepositoryUseCaseProvider: UseCaseProvider, DatabaseContainerProtocol {
    private let _data: Initializer

    public init() {
        let container = Self.initContainer()
        _data = Initializer(container: container, network: API.Network())
    }

    init(container: DS.Container? = nil, network: NetworkProtocol) {
        _data = Initializer(container: container ?? Self.initContainer(),
                            network: network)
    }

    public func makeMenuService() -> MenuUseCase {
        MenuRepository(data: _data)
    }

    public func makeIngredientsService(pizza: AnyPublisher<Pizza, Never>) -> IngredientsUseCase {
        IngredientsRepository(data: _data, pizza: pizza)
    }

    public func makeCartService() -> CartUseCase {
        CartRepository(data: _data)
    }

    public func makeDrinksService() -> DrinksUseCase {
        DrinksRepository(data: _data)
    }

    public func makeSaveService() -> SaveUseCase {
        SaveRepository(data: _data)
    }
}
