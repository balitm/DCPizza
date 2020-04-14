//
//  RepositoryUseCaseProvider.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

public struct RepositoryUseCaseProvider: UseCaseProvider {
    let _container: DS.Container?

    public init() {
        _container = NetworkRepository.initContainer()
    }

    init(container: DS.Container? = nil) {
        if let container = container {
            _container = container
        } else {
            _container = NetworkRepository.initContainer()
        }
    }

    public func makeNetworkUseCase() -> NetworkUseCase {
        return RepositoryNetworkUseCase(container: _container)
    }

    public func makeDatabaseUseCase() -> DatabaseUseCase {
        return RepositoryDatabaseUseCase()
    }
}
