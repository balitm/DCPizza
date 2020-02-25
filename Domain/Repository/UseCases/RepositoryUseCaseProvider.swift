//
//  RepositoryUseCaseProvider.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

public struct RepositoryUseCaseProvider: UseCaseProvider {
    public init() {}
    
    public func makeNetworkUseCase() -> NetworkUseCase {
        return RepositoryNetworkUseCase()
    }

    public func makeDatabaseUseCase() -> DatabaseUseCase {
        return RepositoryDatabaseUseCase()
    }
}
