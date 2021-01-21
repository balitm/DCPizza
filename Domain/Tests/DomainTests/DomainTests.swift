//
//  DomainTests.swift
//  DomainTests
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import XCTest
import RxSwift
import RealmSwift
@testable import Domain

class DomainTests: NetworklessUseCaseTestsBase {
    private let _bag = DisposeBag()
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
        testCart = Cart(pizzas: pizzas, drinks: drinks, basePrice: data.cart.value.basePrice)
    }

    func testNetwork() {
        let network: NetworkProtocol = API.Network()
        let expectation = XCTestExpectation(description: "net")

        Observable.zip(
            network.getIngredients(),
            network.getDrinks()
        )
        .subscribe(onDisposed: {
            XCTAssert(true)
            expectation.fulfill()
        })
        .disposed(by: _bag)

        wait(for: [expectation], timeout: 120.0)
    }

    func testCombinableNetwork() {
        let expectation = XCTestExpectation(description: "combine")

        func success() {
            XCTAssert(true)
            expectation.fulfill()
        }

        let cancellable = Observable.zip(
            API.GetIngredients().rx.perform(),
            API.GetDrinks().rx.perform())
            .subscribe(onNext: {
                DLog("Received #(ingredients: ", $0.0.count, ", drinks: ", $0.1.count, ").")
            }, onError: {
                DLog("Received error: ", $0)
            }, onDisposed: {
                success()
            })

        wait(for: [expectation], timeout: 120.0)
        cancellable.dispose()
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
            .subscribe(onCompleted: {
                DLog("Checkout succeeded.")
                XCTAssert(true)
            }, onError: {
                XCTAssert(false, "Error: \($0).")
            }, onDisposed: {
                expectation.fulfill()
            })
            .disposed(by: _bag)
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
