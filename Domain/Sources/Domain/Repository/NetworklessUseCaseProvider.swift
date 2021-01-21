//
//  NetworklessUseCaseProvider.swift
//  Domain
//
//  Created by Balázs Kilvády on 6/7/20.
//

import Foundation
import RxSwift

public struct NetworklessUseCaseProvider: UseCaseProvider, DatabaseContainerProtocol {
    private let _data: Initializer

    public init() {
        let network: NetworkProtocol = TestNetUseCase()
        let container = NetworklessUseCaseProvider.initContainer()
        _data = Initializer(container: container, network: network)
    }

    public func makeMenuService() -> MenuUseCase {
        MenuRepository(data: _data)
    }

    public func makeIngredientsService(pizza: Observable<Pizza>) -> IngredientsUseCase {
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
