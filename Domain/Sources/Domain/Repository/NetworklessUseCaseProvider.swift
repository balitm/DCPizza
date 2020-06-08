//
//  NetworklessUseCaseProvider.swift
//  Domain
//
//  Created by Balázs Kilvády on 6/7/20.
//

import Foundation
import Combine

public struct NetworklessUseCaseProvider: UseCaseProvider, DatabaseContainerProtocol {
    var container: DS.Container?
    private let _data: Initializer

    public init() {
        let network: NetworkProtocol = TestNetUseCase()
        container = RepositoryUseCaseProvider.initContainer()
        _data = Initializer(container: container, network: network)
    }

    public func makeMenuUseCase() -> MenuUseCase {
        MenuRepository(data: _data)
    }

    public func makeIngredientsService(pizza: AnyPublisher<Pizza, Never>) -> IngredientsUseCase {
        IngredientsRepository(data: _data, pizza: pizza)
    }

    public func makeCartService() -> CartUseCase {
        CartRepository(data: _data)
    }

    public func makeDrinsService() -> DrinksUseCase {
        DrinksRepository(data: _data)
    }

    public func makeSaveService() -> SaveUseCase {
        SaveRepository(data: _data)
    }
}
