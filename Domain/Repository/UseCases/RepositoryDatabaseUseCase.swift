//
//  RepositoryDatabaseUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/23/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

final class RepositoryDatabaseUseCase: DatabaseUseCase {
    let _repository: RepositoryDatabaseProtocol

    init() {
        _repository = DatabaseRepository()
    }

    func deleteCart() {
        _repository.deleteCart()
    }
    
    func save(cart: Cart) {
        _repository.save(cart: cart.asDataSource())
    }
}
