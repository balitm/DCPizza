//
//  NetworklessUseCaseTestsBase.swift
//  Domain
//
//  Created by Balázs Kilvády on 7/20/20.
//

import XCTest
import RealmSwift
import Combine
@testable import Domain

class NetworklessUseCaseTestsBase: UseCaseTestsBase {
    var data: Initializer!
    var component: Initializer.Components!

    override func setUp() {
        super.setUp()

        let network: NetworkProtocol = TestNetUseCase()
        data = Initializer(container: container, network: network)
        component = try! data.component.get()
    }

    func addItemTest(addItem: () -> AnyPublisher<Void, Error>,
                     test: (Cart) -> Void = { XCTAssertEqual($0.pizzas.count, 1) })
    {
        data.cart.empty()
        XCTAssert(data.cart.pizzas.isEmpty)
        XCTAssert(data.cart.drinks.isEmpty)
        expectation { expectation in
            _ = addItem()
                .sink(receiveCompletion: {
                    if case let Subscribers.Completion.failure(error) = $0 {
                        XCTAssert(false, "failed with: \(error)")
                    }
                    expectation.fulfill()
                }, receiveValue: {
                    XCTAssert(true)
                })
        }
        test(data.cart)
    }
}
