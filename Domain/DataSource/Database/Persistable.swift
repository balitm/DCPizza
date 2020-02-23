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

final class WriteTransaction {
    private let _realm: Realm

    init(realm: Realm) {
        _realm = realm
    }

    public func add<T: Persistable>(_ value: T) {
        _realm.add(value.managedObject())
    }
}

final class Container {
    private let _realm: Realm

    convenience init() throws {
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

    func values<T: Persistable> (_ type: T.Type) -> [T] {
        let results = _realm.objects(T.ManagedObject.self)
        return results.map { T(managedObject: $0) }
    }

    func delete<T: Persistable>(_ type: T.Type) throws {
        let objects = _realm.objects(T.ManagedObject.self)
        try _realm.write {
            _realm.delete(objects)
        }
    }
}
