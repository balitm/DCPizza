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

    override func setUp() {
    }

    override func tearDown() {
    }

    func testNetwork() {
        let useCase = RepositoryNetworkUseCaseProvider().makeNetworkUseCase()
        useCase.getIngredients()
            .subscribe()
            .disposed(by: _bag)

        useCase.getDrinks()
            .subscribe()
            .disposed(by: _bag)

        useCase.getInitData()
            .subscribe()
            .disposed(by: _bag)
    }

    func testPizzaConversion() {
        func checkConvertion(_ data: InitData) -> Bool {
            let pizzas = data.pizzas
            let dsPizzas = pizzas.asDataSource()
            return
                dsPizzas.pizzas.count == pizzas.pizzas.count
                    && dsPizzas.pizzas.reduce(true, { r0, pizza in
                        r0 && pizza.ingredients.reduce(true, { r1, id in
                            r1 && data.ingredients.contains { $0.id == id }
                        })
                    })
        }

        let expectation = self.expectation(description: "Convert")
        var isConverted = false
        let useCase = RepositoryNetworkUseCaseProvider().makeNetworkUseCase()
        useCase.getInitData()
            .subscribe(onNext: {
                isConverted = checkConvertion($0)
            }, onDisposed: {
                expectation.fulfill()
            })
            .disposed(by: _bag)

        waitForExpectations(timeout: 30, handler: nil)
        XCTAssertTrue(isConverted)
    }

    func testCartConversion() {
        func checkConvertion(_ cart: Domain.Cart, _ ingredients: [Ingredient]) -> Bool {
            let converted = cart.asDataSource().asDomain(with: ingredients)

            return converted.pizzas.map({ $0.name }) == cart.pizzas.map({ $0.name })
                && converted.drinks == cart.drinks
        }

        let expectation = self.expectation(description: "Convert")
        var isConverted = false
        let useCase = RepositoryNetworkUseCaseProvider().makeNetworkUseCase()
        useCase.getInitData()
            .subscribe(onNext: {
                var cart = $0.cart
                guard !$0.drinks.isEmpty && $0.pizzas.pizzas.count >= 2 else { return }
                cart.add(drink: $0.drinks[0])
                cart.add(pizza: $0.pizzas.pizzas[0])
                cart.add(pizza: $0.pizzas.pizzas[1])
                isConverted = checkConvertion(cart, $0.ingredients)
            }, onDisposed: {
                expectation.fulfill()
            })
            .disposed(by: _bag)

        waitForExpectations(timeout: 30, handler: nil)
        XCTAssertTrue(isConverted)
    }
}
