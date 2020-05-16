//
//  IngredientsUseCaseTests.swift
//
//
//  Created by Balázs Kilvády on 5/16/20.
//

import XCTest
import Combine
@testable import Domain

class IngredientsUseCaseTests: UseCaseTestsBase {
    var useCase: IngredientsRepository!

    override func setUp() {
        super.setUp()

        useCase = IngredientsRepository(data: data)
    }

    func testIngredients() {
        exception { expectation in
            _ = useCase.ingredients()
                .first()
                .sink(receiveValue: {
                    DLog("all ingredients: ", $0.count)
                    XCTAssertGreaterThan($0.count, 0)
                    expectation.fulfill()
                })
        }
    }
}

extension IngredientsRepository: HasAddPizza {}

extension IngredientsUseCaseTests: AddPizzaTest {
    func testAddPizza() {
        addPizzaTest()
    }
}
