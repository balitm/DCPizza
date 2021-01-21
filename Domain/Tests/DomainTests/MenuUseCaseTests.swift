//
//  MenuUseCaseTests.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/15/20.
//

import XCTest
import RxSwift
@testable import Domain

class MenuUseCaseTests: NetworklessUseCaseTestsBase {
    var service: MenuRepository!

    override func setUp() {
        super.setUp()

        service = MenuRepository(data: data)
    }

    func testPizzas() {
        expectation { expectation in
            _ = service.pizzas()
                .take(1)
                .subscribe(onNext: {
                    switch $0 {
                    case let .failure(error):
                        XCTAssert(false, "Received error: \(error)")
                    case let .success(pizzas):
                        DLog("all pizzas: ", pizzas.pizzas.count)
                        XCTAssertGreaterThan(pizzas.pizzas.count, 0)
                    }
                    expectation.fulfill()
                })
        }
    }

    func testAddPizza() {
        addItemTest(addItem: { [useCase = service!, component = component!] in
            let pizza = component.pizzas.pizzas.first!
            return useCase.addToCart(pizza: pizza)
        })
    }
}
