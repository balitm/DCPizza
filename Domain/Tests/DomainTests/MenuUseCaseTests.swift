//
//  MenuUseCaseTests.swift
//
//
//  Created by Balázs Kilvády on 5/15/20.
//

import XCTest
import Combine
@testable import Domain

class MenuUseCaseTests: UseCaseTestsBase {
    var useCase: MenuUseCase!

    override func setUp() {
        super.setUp()

        useCase = MenuRepository(data: data)
    }

    private func _exception(test: (XCTestExpectation) -> Void) {
        let expectation = XCTestExpectation(description: "combine")
        test(expectation)
        wait(for: [expectation], timeout: 3.0)
    }

    func testPizzas() {
        _exception { expectation in
            _ = useCase.pizzas()
                .first()
                .sink(receiveValue: {
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
        data.cart.empty()
        XCTAssert(data.cart.pizzas.isEmpty)
        XCTAssert(data.cart.drinks.isEmpty)
        _exception { expectation in
            _ = useCase.addPizza(pizza: component.pizzas.pizzas.first!)
                .sink(receiveCompletion: {
                    if case let Subscribers.Completion.failure(error) = $0 {
                        XCTAssert(false, "failed with: \(error)")
                    }
                    expectation.fulfill()
                }, receiveValue: {
                    XCTAssert(true)
                })
        }
        XCTAssertEqual(data.cart.pizzas.count, 1)
    }

    func testSaveCart() {
        guard component.drinks.count >= 2 && component.pizzas.pizzas.count >= 2 else {
            XCTAssert(false, "no enough components.")
            return
        }

        let pizzas = [
            component.pizzas.pizzas[0],
            component.pizzas.pizzas[1],
        ]
        let drinks = [
            component.drinks[0],
            component.drinks[1],
        ]
        data.cart = Cart(pizzas: pizzas, drinks: drinks, basePrice: data.cart.basePrice)

        _exception { expectation in
            _ = useCase.saveCart()
                .sink(receiveCompletion: {
                    if case let Subscribers.Completion.failure(error) = $0 {
                        XCTAssert(false, "failed with: \(error)")
                    }
                    expectation.fulfill()
                }, receiveValue: {
                    XCTAssert(true)
                })
        }

        do {
            let carts = container.values(DS.Cart.self)
            XCTAssertEqual(carts.count, 1)
            let cart = carts.first!
            XCTAssertEqual(cart.pizzas.count, 2)
            XCTAssertEqual(cart.drinks.count, 2)
            cart.drinks.enumerated().forEach {
                XCTAssertEqual($0.element, component.drinks[$0.offset].id)
            }
            cart.pizzas.enumerated().forEach {
                XCTAssertEqual($0.element.name, component.pizzas.pizzas[$0.offset].name)
            }
            try container.write({
                $0.delete(DS.Pizza.self)
                $0.delete(DS.Cart.self)
            })
        } catch {
            XCTAssert(false, "Database threw \(error)")
        }
    }
}
