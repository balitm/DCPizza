//
//  DrinksUseCaseTests.swift
//
//
//  Created by Balázs Kilvády on 5/20/20.
//

import XCTest
import Combine
@testable import Domain

class DrinksUseCaseTests: NetworklessUseCaseTestsBase {
    var service: DrinksUseCase!

    override func setUp() {
        super.setUp()

        service = DrinksRepository(data: data)
    }

    func testDrinks() {
        expectation { expectation in
            _ = service.drinks()
                .sink(receiveCompletion: {
                    if case Subscribers.Completion<Never>.finished = $0 {
                        expectation.fulfill()
                    }
                }, receiveValue: {
                    XCTAssertGreaterThan($0.count, 0)
                    expectation.fulfill()
                })
        }
    }

    func testAddDrink() {
        addItemTest { [service = service!] in
            service.addToCart(drinkIndex: 0)
        } test: { [unowned data = data!] in
            XCTAssertEqual($0.drinks.count, 1)
            XCTAssertEqual($0.drinks[0].id, try? data.component.get().drinks[0].id)
        }
    }
}
