//
//  MenuUseCaseTests.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/15/20.
//

import XCTest
import Combine
@testable import Domain

class MenuUseCaseTests: NetworklessUseCaseTestsBase {
    var service: MenuRepository!

    override func setUp() {
        super.setUp()

        service = MenuRepository(data: data)
    }

    func testPizzas() {
        var c: AnyCancellable?

        expectation { expectation in
            c = service.pizzas()
                .first()
                .sink(receiveValue: {
                    if let error = $0.error {
                        XCTAssert(false, "Received error: \(error)")
                    } else {
                        let pizzas = $0.pizzas
                        DLog("all pizzas: ", pizzas.pizzas.count)
                        XCTAssertGreaterThan(pizzas.pizzas.count, 0)
                    }
                    expectation.fulfill()
                })
        }
        c?.cancel()
    }

    func testAddPizza() {
        addItemTest(addItem: { [useCase = service!, component = component!] in
            let pizza = component.pizzas.pizzas.first!
            return useCase.addToCart(pizza: pizza)
        })
    }
}
