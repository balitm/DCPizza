//
//  DrinksUseCaseTests.swift
//
//
//  Created by Balázs Kilvády on 5/20/20.
//

import XCTest
import RxSwift
@testable import Domain

class DrinksUseCaseTests: NetworklessUseCaseTestsBase {
    var service: DrinksUseCase!

    override func setUp() {
        super.setUp()

        service = DrinksRepository(data: data)
    }

    func testDrinks() {
        expectation(timeout: 5.0) { expectation in
            _ = service.drinks()
                .take(1)
                .subscribe(onNext: {
                    XCTAssertGreaterThan($0.count, 0)
                }, onCompleted: {
                    expectation.fulfill()
                })
        }
    }

    func testAddDrink() {
        addItemTest(addItem: { [service = service!] in
            service.addToCart(drinkIndex: 0)
        }, test: {
            XCTAssertEqual($0.drinks.count, 1)
        })
    }
}
