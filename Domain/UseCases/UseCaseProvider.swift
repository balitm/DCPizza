//
//  NetworkUseCaseProvider.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

public protocol UseCaseProvider {
    func makeNetworkUseCase() -> NetworkUseCase
    func makeDatabaseUseCase() -> DatabaseUseCase
}
