//
//  DCPizzaTests.swift
//  DCPizzaTests
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import XCTest
import RxSwift
@testable import Domain
@testable import DCPizza

class DCPizzaTests: XCTestCase {
    private let _bag = DisposeBag()
    var initData: InitData!
    var useCase: NetworkUseCase!

    lazy var initialSetupFinished: XCTestExpectation = {
        let initialSetupFinished = expectation(description: "initial setup finished")

        let useCase = RepositoryNetworkUseCaseProvider().makeNetworkUseCase()
        self.useCase = useCase
        useCase.getInitData()
            .subscribe(onNext: { [unowned self] in
                self.initData = $0
                }, onDisposed: {
                    initialSetupFinished.fulfill()
            })
            .disposed(by: _bag)

        return initialSetupFinished
    }()

    override func setUp() {
        super.setUp()

        wait(for: [initialSetupFinished], timeout: 30.0)
    }

    override func tearDown() {}

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
        DLog("converted:\n", converted.drinks.map { $0.drink.id }, "\norig:\n", cart.drinks.map { $0.id })
        let isConverted = converted.pizzas.map({ $0.pizza.name }) == cart.pizzas.map({ $0.pizza.name })
            && converted.drinks.map { $0.drink.id } == cart.drinks.map { $0.drink.id }

        XCTAssertTrue(isConverted)
    }

    func testCartRemove() {
        var cart = initData.cart.asUI()
        guard initData.drinks.count >= 2 && initData.pizzas.pizzas.count >= 2 else { return }
        cart.add(drink: initData.drinks[0])
        cart.add(drink: initData.drinks[1])
        cart.add(pizza: initData.pizzas.pizzas[0])
        cart.add(pizza: initData.pizzas.pizzas[1])
        cart.remove(at: 1)
        cart.remove(at: 1)
        XCTAssertEqual(cart.pizzas.count, 1)
        XCTAssertEqual(cart.drinks.count, 1)
        XCTAssertEqual(cart.pizzas[0].pizza.name, initData.pizzas.pizzas[0].name)
        XCTAssertEqual(cart.drinks[0].drink.id, initData.drinks[1].id)
    }

    func testCheckout() {
        var cart = initData.cart.asUI()
        guard initData.drinks.count >= 2 && initData.pizzas.pizzas.count >= 2 else { return }
        cart.add(drink: initData.drinks[0])
        cart.add(drink: initData.drinks[1])
        cart.add(pizza: initData.pizzas.pizzas[0])
        cart.add(pizza: initData.pizzas.pizzas[1])
        let expectation = XCTestExpectation(description: "checkout")

        useCase.checkout(cart: cart.asDomain())
            .subscribe(onNext: { _ in
                DLog("Checkout succeeded.")
                XCTAssert(true)
            }, onError: { _ in
                XCTAssert(false)
            }, onDisposed: {
                expectation.fulfill()
            })
            .disposed(by: _bag)

        wait(for: [expectation], timeout: 30.0)
    }
}
