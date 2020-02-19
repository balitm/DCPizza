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

        useCase.getPizzas()
            .subscribe()
            .disposed(by: _bag)
    }

    func testEntityConversion() {
        func checkConvertion(_ pair: (pizzas: Pizzas, ingredients: [Ingredient])) -> Bool {
            let pizzas = pair.pizzas
            let dsPizzas = pizzas.asDataSource()
            return
                dsPizzas.pizzas.count == pizzas.pizzas.count
                    && dsPizzas.pizzas.reduce(true, { r0, pizza in
                        r0 && pizza.ingredients.reduce(true, { r1, id in
                            r1 && pair.ingredients.contains { $0.id == id }
                        })
                    })
        }

        let expectation = self.expectation(description: "Convert")
        var isConverted = false
        let useCase = RepositoryNetworkUseCaseProvider().makeNetworkUseCase()
        useCase.getPizzas()
            .subscribe(onNext: {
                isConverted = checkConvertion($0)
            }, onDisposed: {
                expectation.fulfill()
            })
            .disposed(by: _bag)

        waitForExpectations(timeout: 30, handler: nil)
        XCTAssertTrue(isConverted)
    }
}
