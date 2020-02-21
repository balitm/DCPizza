//
//  DomainTests.swift
//  DomainTests
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import XCTest
import RxSwift
@testable import Domain

class DomainTests: XCTestCase {
    private let _bag = DisposeBag()
    var initData: InitData!

    lazy var initialSetupFinished: XCTestExpectation = {
        let initialSetupFinished = expectation(description: "initial setup finished")

        let useCase = RepositoryNetworkUseCaseProvider().makeNetworkUseCase()
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

    func testNetwork() {
        let useCase = RepositoryNetworkUseCaseProvider().makeNetworkUseCase()
        useCase.getIngredients()
            .subscribe()
            .disposed(by: _bag)

        useCase.getDrinks()
            .subscribe()
            .disposed(by: _bag)
    }

    func testPizzaConversion() {
        let pizzas = initData.pizzas
        let dsPizzas = pizzas.asDataSource()
        let isConverted =
            dsPizzas.pizzas.count == pizzas.pizzas.count
                && dsPizzas.pizzas.reduce(true, { r0, pizza in
                    r0 && pizza.ingredients.reduce(true, { r1, id in
                        r1 && initData.ingredients.contains { $0.id == id }
                    })
                })

        XCTAssertTrue(isConverted)
    }

    func testCartConversion() {
        var cart = initData.cart
        guard initData.drinks.count >= 2 && initData.pizzas.pizzas.count >= 2 else { return }
        cart.add(drink: initData.drinks[0])
        cart.add(drink: initData.drinks[1])
        cart.add(pizza: initData.pizzas.pizzas[0])
        cart.add(pizza: initData.pizzas.pizzas[1])

        let converted = cart.asDataSource().asDomain(with: initData.ingredients, drinks: initData.drinks)
        DLog("converted:\n", converted.drinks.map { $0.id }, "\norig:\n", cart.drinks.map { $0.id })
        let isConverted = converted.pizzas.map({ $0.name }) == cart.pizzas.map({ $0.name })
            && converted.drinks.map { $0.id } == cart.drinks.map { $0.id }

        XCTAssertTrue(isConverted)
    }

    func testCartRemove() {
        var cart = initData.cart
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
}
