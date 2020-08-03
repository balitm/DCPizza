//
//  IngredientsUseCaseTests.swift
//
//
//  Created by Balázs Kilvády on 5/16/20.
//

import XCTest
import Combine
@testable import Domain

class IngredientsUseCaseTests: NetworklessUseCaseTestsBase {
    var service: IngredientsRepository!

    override func setUp() {
        super.setUp()

        let pizza = component.pizzas.pizzas[0]
        service = IngredientsRepository(data: data, pizza: Just(pizza).eraseToAnyPublisher())
    }

    func testIngredients() {
        let selected = CurrentValueSubject<Int, Never>(0)

        expectation { expectation in
            _ = service.ingredients(selected: AnyPublisher(selected))
                .sink(receiveValue: {
                    XCTAssertGreaterThan($0.count, 0)
                })

            selected.send(1)
            expectation.fulfill()
        }
    }

    func testAddPizza() {
        addItemTest(addItem: { [service = service!] in
            service.addToCart()
        })
    }
}
