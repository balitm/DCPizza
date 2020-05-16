//
//  DCPizzaTests.swift
//  DCPizzaTests
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import XCTest
import Combine
@testable import Domain
@testable import DCPizza

class DCPizzaTests: XCTestCase {
    private var _bag = Set<AnyCancellable>()
    var initData: InitData!
    var useCase: NetworkUseCase!

    lazy var initialSetupFinished: XCTestExpectation = {
        let initialSetupFinished = expectation(description: "initial setup finished")

        let useCase = RepositoryUseCaseProvider().makeNetworkUseCase()
        self.useCase = useCase
        useCase.getInitData()
            .sink(receiveCompletion: { _ in
                initialSetupFinished.fulfill()
            }, receiveValue: { [unowned self] in
                self.initData = $0
            })
            .store(in: &_bag)

        return initialSetupFinished
    }()

    override func setUp() {
        super.setUp()

        wait(for: [initialSetupFinished], timeout: 30.0)
    }

    override func tearDown() {}

    func testCartRemove() {
        var cart = Cart.empty
        guard initData.drinks.count >= 2 && initData.pizzas.pizzas.count >= 2 else { return }
        cart.add(drink: initData.drinks[0])
        cart.add(drink: initData.drinks[1])
        cart.add(pizza: initData.pizzas.pizzas[0])
        cart.add(pizza: initData.pizzas.pizzas[1])
        cart.remove(at: 1)
        cart.remove(at: 1)
        XCTAssertEqual(cart.pizzas.count, 1)
        XCTAssertEqual(cart.drinks.count, 1)
        XCTAssertEqual(cart.pizzas[0].name, initData.pizzas.pizzas[0].name)
        XCTAssertEqual(cart.drinks[0].id, initData.drinks[1].id)
    }

    func testCheckout() {
        var cart = initData.cart
        guard initData.drinks.count >= 2 && initData.pizzas.pizzas.count >= 2 else { return }
        cart.add(drink: initData.drinks[0])
        cart.add(drink: initData.drinks[1])
        cart.add(pizza: initData.pizzas.pizzas[0])
        cart.add(pizza: initData.pizzas.pizzas[1])

        do {
            let container = try DS.Container()
            try container.write {
                $0.add(cart.asDataSource())
            }
            XCTAssert(
                !container.values(DS.Cart.self).isEmpty
                    && !container.values(DS.Pizza.self).isEmpty
            )

            let expectation = XCTestExpectation(description: "checkout")

            useCase.checkout(cart: cart)
                .sink(receiveCompletion: {
                    if case let Subscribers.Completion<API.ErrorType>.failure(error) = $0 {
                        DLog("failed with: ", error)
                        XCTAssert(false)
                    }
                    expectation.fulfill()
                }, receiveValue: { _ in
                    DLog("Checkout succeeded.")
                    XCTAssert(true)
                })
                .store(in: &_bag)

            wait(for: [expectation], timeout: 30.0)

            XCTAssert(
                container.values(DS.Cart.self).isEmpty
                    && container.values(DS.Pizza.self).isEmpty
            )
        } catch {
            XCTAssert(false)
            return
        }
    }
}
