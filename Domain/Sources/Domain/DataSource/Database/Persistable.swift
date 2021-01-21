//
//  Persistable.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/23/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import RealmSwift

protocol Persistable {
    associatedtype ManagedObject: Object

    init(managedObject: ManagedObject)
    func managedObject() -> ManagedObject
}

extension DataSource {
    final class WriteTransaction {
        private let _realm: Realm

        init(realm: Realm) {
            _realm = realm
        }

        public func add<T: Persistable>(_ value: T) {
            _realm.add(value.managedObject())
        }

        public func delete<T: Persistable>(_ type: T.Type) {
            let objects = _realm.objects(T.ManagedObject.self)
            _realm.delete(objects)
        }
    }

    final class Container {
        private let _realm: Realm

        convenience init() throws {
            let config = Realm.Configuration.defaultConfiguration
            DLog(">>> realm path: ", config.fileURL!.path)
            try self.init(realm: Realm())
        }

        init(realm: Realm) {
            _realm = realm
        }

        func write(_ block: (WriteTransaction) throws -> Void) throws {
            let transaction = WriteTransaction(realm: _realm)
            try _realm.write {
                try block(transaction)
            }
        }

        func values<T: Persistable>(_ type: T.Type) -> [T] {
            let results = _realm.objects(T.ManagedObject.self)
            return results.map { T(managedObject: $0) }
        }
    }
}
