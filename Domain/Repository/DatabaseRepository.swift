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
    func save(cart: DS.Cart )
}

struct DatabaseRepository: RepositoryDatabaseProtocol {
    private let _container: Container?

    init() {
        do {
            _container = try Container()
        } catch {
            DLog("# DB init failed.")
            _container = nil
        }
    }

    func deleteCart() {
        _execute {
            try $0.delete(DS.Cart.self)
        }
    }

    func save(cart: DS.Cart) {
        _execute {
            try $0.write {
                $0.add(cart)
            }
        }
    }

    private func _execute(_ block: (Container) throws -> Void) {
        guard let container = _container else {
            DLog("# No usable DB container.")
            return
        }
        do {
            try block(container)
        } catch {
            DLog("# DB operation failed.")
        }
    }
}
