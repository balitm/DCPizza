//
//  UseCaseTestsBase.swift
//
//
//  Created by Balázs Kilvády on 5/15/20.
//

import XCTest
import RealmSwift
import Combine
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
            try DS.dbQueue.sync {
                let config = _realmConfig
                realm = try Realm(configuration: config, queue: DS.dbQueue)
            }
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

    func expectation(timeout: Double = 30.0, test: (XCTestExpectation) -> Void) {
        let expectation = XCTestExpectation(description: "combine")
        test(expectation)
        wait(for: [expectation], timeout: timeout)
    }

    func addItemTest(addItem: () -> AnyPublisher<Void, Error>,
                     test: (Cart) -> Void = { XCTAssertEqual($0.pizzas.count, 1) }) {
        data.cart.empty()
        XCTAssert(data.cart.pizzas.isEmpty)
        XCTAssert(data.cart.drinks.isEmpty)
        var c: AnyCancellable?
        expectation { expectation in
            c = addItem()
                .sink(receiveCompletion: {
                    if case let Subscribers.Completion.failure(error) = $0 {
                        XCTAssert(false, "failed with: \(error)")
                    }
                    expectation.fulfill()
                }, receiveValue: {
                    XCTAssert(true)
                })
        }
        c?.cancel()
        test(data.cart)
    }
}
