//
//  IngredientsUseCaseTests.swift
//
//
//  Created by Balázs Kilvády on 5/16/20.
//

import XCTest
import RxSwift
@testable import Domain

class IngredientsUseCaseTests: NetworklessUseCaseTestsBase {
    var service: IngredientsRepository!

    override func setUp() {
        super.setUp()

        let pizza = component.pizzas.pizzas[0]
        service = IngredientsRepository(data: data, pizza: Observable.just(pizza))
    }

    func testIngredients() {
        let selected = BehaviorSubject(value: 0)

        expectation { expectation in
            _ = service.ingredients(selected: selected)
                .subscribe(onNext: {
                    XCTAssertGreaterThan($0.count, 0)
                })

            selected.on(.next(1))
            expectation.fulfill()
        }
    }

    func testAddPizza() {
        addItemTest(addItem: { [service = service!] in
            service.addToCart()
        })
    }
}
