//
//  RepositoryDatabaseUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/23/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

protocol RepositoryDatabaseProtocol {
    func deleteCart()
    func save(cart: DS.Cart)
}

struct DatabaseRepository: RepositoryDatabaseProtocol, DatabaseContainerProtocol {
    let container: DS.Container?

    init() {
        container = DatabaseRepository.initContainer()
    }

    func deleteCart() {
        execute {
            try $0.write({
                $0.delete(DS.Cart.self)
            })
        }
    }

    func save(cart: DS.Cart) {
        execute {
            try $0.write {
                $0.delete(DS.Cart.self)
                $0.add(cart)
            }
        }
    }
}
