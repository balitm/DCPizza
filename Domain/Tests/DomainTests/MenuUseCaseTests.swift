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
    var useCase: MenuRepository!

    override func setUp() {
        super.setUp()

        useCase = MenuRepository(data: data)
    }

    func testPizzas() {
        exception { expectation in
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

        exception { expectation in
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

extension MenuRepository: HasAddPizza {}

extension MenuUseCaseTests: AddPizzaTest {
    func testAddPizza() {
        addPizzaTest()
    }
}
