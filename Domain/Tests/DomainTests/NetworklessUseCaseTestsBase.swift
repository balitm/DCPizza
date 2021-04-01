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

    func addItemTest(addItem: @escaping () -> AnyPublisher<Void, Error>,
                     test: @escaping (Cart) -> Void = { XCTAssertEqual($0.pizzas.count, 1) }) {
        expectation { [unowned data = data!] expectation in
            // Empty the cart.
            _ = data.cartHandler.trigger(action: .empty)
                .handleEvents(receiveCompletion: {
                    if case let Subscribers.Completion.failure(error) = $0 {
                        XCTAssert(false, "\(error)")
                    }
                }, receiveCancel: {
                    XCTAssert(false, "cancelled")
                })
                .catch { _ in Empty<Void, Never>() }
                .flatMap { _ in
                    // Check if cart is empty.
                    data.cartHandler.cartResult
                        .first()
                        .map(\.cart)
                        .handleEvents(receiveOutput: {
                            XCTAssert($0.pizzas.isEmpty)
                            XCTAssert($0.drinks.isEmpty)
                        })
                }
                .flatMap { _ in
                    // Add item.
                    addItem()
                        .handleEvents(receiveOutput: {
                            XCTAssert(true)
                        }, receiveCompletion: {
                            if case let Subscribers.Completion.failure(error) = $0 {
                                XCTAssert(false, "failed with: \(error)")
                            }
                        })
                        .catch { _ in Empty<Void, Never>() }
                }
                .flatMap {
                    data.cartHandler.cartResult
                        .first()
                        .map(\.cart)
                }
                .sink {
                    test($0)
                    expectation.fulfill()
                }
        }
    }
}
