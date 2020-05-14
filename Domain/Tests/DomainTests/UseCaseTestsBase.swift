//
//  UseCaseTestsBase.swift
//
//
//  Created by Balázs Kilvády on 5/15/20.
//

import XCTest
import RealmSwift
@testable import Domain

class UseCaseTestsBase: XCTestCase {
    var data: Initializer!
    var component: Initializer.Components!
    static var realm: Realm!
    var container: DS.Container!

    override class func setUp() {
        super.setUp()

        var _realmConfig: Realm.Configuration {
            var config = Realm.Configuration.defaultConfiguration
            DLog("Realm file: \(config.fileURL!.path)")
            var fileURL = config.fileURL!
            fileURL.deleteLastPathComponent()
            fileURL.deleteLastPathComponent()
            fileURL.appendPathComponent("tmp")
            fileURL.appendPathComponent("test.realm")
            DLog("Realm file: \(fileURL.path)")
            config.fileURL = fileURL
            return config
        }

        do {
            let config = _realmConfig
            realm = try Realm(configuration: config)
        } catch {
            fatalError("test realm can't be inited:\n\(error)")
        }
    }

    override func setUp() {
        super.setUp()

        container = DS.Container(realm: UseCaseTestsBase.realm)
        let network: NetworkProtocol = TestNetUseCase()
        data = Initializer(container: container, network: network)
        component = try! data.component.get()
    }
}
