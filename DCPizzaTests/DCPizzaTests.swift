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

    func testCartSlices() {
        var cart = Cart(pizzas: [], drinks: [], basePrice: 0).asUI()
        guard initData.drinks.count >= 2 && initData.pizzas.pizzas.count >= 2 else { return }

        XCTAssertEqual(cart.pizzaIds.count, 0)
        XCTAssertEqual(cart.drinkIds.count, 0)

        cart.add(drink: initData.drinks[0])
        cart.add(drink: initData.drinks[1])
        XCTAssertEqual(cart.pizzaIds.count, 0)
        XCTAssertEqual(cart.drinkIds.count, 2)
        XCTAssertEqual(cart.drinkIds, [0, 1])

        cart.empty()
        cart.add(pizza: initData.pizzas.pizzas[0])
        cart.add(pizza: initData.pizzas.pizzas[1])
        XCTAssertEqual(cart.pizzaIds.count, 2)
        XCTAssertEqual(cart.drinkIds.count, 0)
        XCTAssertEqual(cart.pizzaIds, [0, 1])

        cart.empty()
        cart.add(drink: initData.drinks[0])
        cart.add(drink: initData.drinks[1])
        cart.add(pizza: initData.pizzas.pizzas[0])
        cart.add(pizza: initData.pizzas.pizzas[1])
        XCTAssertEqual(cart.pizzaIds.count, 2)
        XCTAssertEqual(cart.drinkIds.count, 2)
        XCTAssertEqual(cart.pizzaIds, [2, 3])
        XCTAssertEqual(cart.drinkIds, [0, 1])
    }

    func testCartConversion() {
        var cart = initData.cart.asUI()
        guard initData.drinks.count >= 2 && initData.pizzas.pizzas.count >= 2 else { return }
        cart.add(drink: initData.drinks[0])
        cart.add(drink: initData.drinks[1])
        cart.add(pizza: initData.pizzas.pizzas[0])
        cart.add(pizza: initData.pizzas.pizzas[1])

        let converted = cart
            .asDomain()
            .asDataSource()
            .asDomain(with: initData.ingredients, drinks: initData.drinks)
            .asUI()
        DLog("converted:\n", converted.drinks.map { $0.id }, "\norig:\n", cart.drinks.map { $0.id })
        let isConverted = converted.pizzas.map({ $0.name }) == cart.pizzas.map({ $0.name })
            && converted.drinks.map { $0.id } == cart.drinks.map { $0.id }

        XCTAssertTrue(isConverted)
    }

    func testCartRemove() {
        var cart = UI.Cart.empty
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
        var cart = initData.cart.asUI()
        guard initData.drinks.count >= 2 && initData.pizzas.pizzas.count >= 2 else { return }
        cart.add(drink: initData.drinks[0])
        cart.add(drink: initData.drinks[1])
        cart.add(pizza: initData.pizzas.pizzas[0])
        cart.add(pizza: initData.pizzas.pizzas[1])

        do {
            let container = try DS.Container()
            try container.write {
                $0.add(cart.asDomain().asDataSource())
            }
            XCTAssert(
                !container.values(DS.Cart.self).isEmpty
                    && !container.values(DS.Pizza.self).isEmpty
            )

            let expectation = XCTestExpectation(description: "checkout")

            useCase.checkout(cart: cart.asDomain())
                .sink(receiveCompletion: {
                    if case let Subscribers.Completion<Error>.failure(error) = $0 {
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
