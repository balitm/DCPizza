//
//  DomainTests.swift
//  DomainTests
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import XCTest
import Combine
import RealmSwift
@testable import Domain

class DomainTests: UseCaseTestsBase {
    private var _bag = Set<AnyCancellable>()
    var testCart: Cart!

    override func setUp() {
        super.setUp()

        guard component.drinks.count >= 2 && component.pizzas.pizzas.count >= 2 else { return }
        let pizzas = [
            component.pizzas.pizzas[0],
            component.pizzas.pizzas[1],
        ]
        let drinks = [
            component.drinks[0],
            component.drinks[1],
        ]
        testCart = Cart(pizzas: pizzas, drinks: drinks, basePrice: data.cart.basePrice)
    }

    override func tearDown() {
        DLog("cancellables: ", _bag.count)
    }

    func testNetwork() {
        let network: NetworkProtocol = API.Network()
        let expectation = XCTestExpectation(description: "net")

        Publishers.Zip(
            network.getIngredients(),
            network.getDrinks()
        )
        .sink(receiveCompletion: { _ in
            XCTAssert(true)
            expectation.fulfill()
        }, receiveValue: { _ in
        })
        .store(in: &_bag)

        wait(for: [expectation], timeout: 120.0)
    }

    func testCombinableNetwork() {
        let expectation = XCTestExpectation(description: "combine")

        func success() {
            XCTAssert(true)
            expectation.fulfill()
        }

        let cancellable = Publishers.Zip(API.getIngredients(),
                                         API.getDrinks())
            .sink(receiveCompletion: {
                DLog("Received comletion: ", $0)
                success()
            }, receiveValue: {
                DLog("Received #(ingredients: ", $0.0.count, ", drinks: ", $0.1.count, ").")
                success()
            })

        wait(for: [expectation], timeout: 120.0)
        cancellable.cancel()
    }

    func testPizzaConversion() {
        let pizzas = component.pizzas
        let dsPizzas = pizzas.asDataSource()
        let isConverted =
            dsPizzas.pizzas.count == pizzas.pizzas.count
                && dsPizzas.pizzas.reduce(true) { r0, pizza in
                    r0 && pizza.ingredients.reduce(true) { r1, id in
                        r1 && component.ingredients.contains { $0.id == id }
                    }
                }

        XCTAssertTrue(isConverted)
    }

    func testCartConversion() {
        let cart = testCart!

        let converted = cart.asDataSource().asDomain(with: component.ingredients, drinks: component.drinks)
        DLog("converted:\n", converted.drinks.map { $0.id }, "\norig:\n", cart.drinks.map { $0.id })
        let isConverted = _isEqual(converted, rhs: cart)
        XCTAssertTrue(isConverted)
    }

    func testCheckout() {
        let network: NetworkProtocol = API.Network()
        let cart = testCart!

        let expectation = XCTestExpectation(description: "checkout")
        network.checkout(cart: cart.asDataSource())
            .sink(receiveCompletion: {
                switch $0 {
                case .failure:
                    XCTAssert(false)
                case .finished:
                    break
                }
                expectation.fulfill()
            }, receiveValue: { _ in
                DLog("Checkout succeeded.")
                XCTAssert(true)
            })
            .store(in: &_bag)

        wait(for: [expectation], timeout: 30.0)
    }

    func testDB() {
        do {
            let realm = DomainTests.realm!
            let container = DS.Container(realm: realm)

            // Save the btest cart.
            try container.write {
                $0.add(testCart.asDataSource())
            }

            // Load saved cart.
            guard let dCart = container.values(DS.Cart.self).first else {
                XCTAssert(false)
                return
            }

            // Delete from DB.
            try container.write {
                $0.delete(DS.Cart.self)
                $0.delete(DS.Pizza.self)
            }

            // Compare.
            let converted = dCart.asDomain(with: component.ingredients, drinks: component.drinks)
            XCTAssertTrue(_isEqual(converted, rhs: testCart))
            return
        } catch {
            DLog(">>> error caught: ", error)
        }
        XCTAssert(false)
    }

    private func _isEqual(_ lhs: Domain.Cart, rhs: Domain.Cart) -> Bool {
        lhs.pizzas.map { $0.name } == rhs.pizzas.map { $0.name }
            && lhs.drinks.map { $0.id } == rhs.drinks.map { $0.id }
    }
}
