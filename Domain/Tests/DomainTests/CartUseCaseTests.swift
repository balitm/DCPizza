//
//  CartUseCaseTests.swift
//
//
//  Created by Balázs Kilvády on 5/17/20.
//

import XCTest
import Combine
import RealmSwift
@testable import Domain

class CartUseCaseTests: UseCaseTestsBase {
    var service: CartUseCase!

    override func setUp() {
        super.setUp()

        service = CartRepository(data: data)
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
        data.cart = Cart.empty
        pizzas.forEach {
            data.cart.add(pizza: $0)
        }
        drinks.forEach {
            data.cart.add(drink: $0)
        }
    }

    func testItems() {
        expectation { expectation in
            _ = service.items()
                .sink(receiveValue: {
                    XCTAssertEqual($0.count, 4)
                    let pizzas = self._pizzaIndexes($0)
                    let drins = self._drinkIndexes($0)
                    XCTAssertEqual(pizzas, [0, 1])
                    XCTAssertEqual(drins, [2, 3])
                    expectation.fulfill()
                })
        }
    }

    func testRemove() {
        expectation { expectation in
            // Remove the 1st pizza.
            _ = service.remove(at: 0)
                .sink(receiveCompletion: {
                    switch $0 {
                    case .finished:
                        DLog("finished.")
                        XCTAssertEqual(self.data.cart.pizzas.count, 1)
                        XCTAssertEqual(self.data.cart.drinks.count, 2)
                        XCTAssertEqual(self.data.cart.pizzas[0].name, self.component.pizzas.pizzas[1].name)
                        expectation.fulfill()
                    case let .failure(error):
                        XCTAssert(false, "\(error)")
                    }
                }, receiveValue: {})
        }

        expectation { expectation in
            // Remove the 1st drink.
            _ = service.remove(at: 1)
                .sink(receiveCompletion: {
                    switch $0 {
                    case .finished:
                        DLog("finished.")
                        XCTAssertEqual(self.data.cart.pizzas.count, 1)
                        XCTAssertEqual(self.data.cart.drinks.count, 1)
                        XCTAssertEqual(self.data.cart.drinks[0].name, self.component.drinks[1].name)
                        expectation.fulfill()
                    case let .failure(error):
                        XCTAssert(false, "\(error)")
                    }
                }, receiveValue: {})
        }
    }

    func testTotoal() {
        var total = 0.0

        expectation { expectation in
            _ = service.total()
                .first()
                .sink(receiveCompletion: {
                    switch $0 {
                    case .finished:
                        DLog("finished.")
                        expectation.fulfill()
                    case let .failure(error):
                        XCTAssert(false, "\(error)")
                    }
                }, receiveValue: {
                    let pp = self.data.cart.pizzas.reduce(0.0) {
                        $0 + $1.ingredients.reduce(self.data.cart.basePrice) {
                            $0 + $1.price
                        }
                    }
                    let dp = self.data.cart.drinks.reduce(0.0) {
                        $0 + $1.price
                    }

                    XCTAssertEqual($0, pp + dp)
                    total = $0
                })
        }

        expectation { expectation in
            _ = service.items()
                .first()
                .sink(receiveValue: {
                    let t = $0.reduce(0.0) { $0 + $1.price }
                    XCTAssertEqual(total, t)
                    expectation.fulfill()
                })
        }
    }

    func testCheckout() {
        let data = Initializer(container: container, network: API.Network())
        data.cart = self.data.cart
        service = CartRepository(data: data)
        var cancellable: AnyCancellable?

        expectation { expectation in
            cancellable = data.$component
                .filter({
                    if let c = try? $0.get() {
                        return !c.pizzas.pizzas.isEmpty
                    }
                    return false
                })
                .sink(receiveValue: { _ in
                    expectation.fulfill()
            })
        }
        cancellable?.cancel()

        expectation { expectation in
            cancellable = service.checkout()
                .sink(receiveCompletion: {
                    switch $0 {
                    case .finished:
                        DLog("finished.")
                        expectation.fulfill()
                    case let .failure(error):
                        XCTAssert(false, "\(error)")
                    }
                }, receiveValue: {})
        }
        cancellable?.cancel()

        XCTAssert(data.cart.pizzas.isEmpty)
        XCTAssert(data.cart.drinks.isEmpty)
        XCTAssert(CartUseCaseTests.realm.objects(RMPizza.self).isEmpty)
        XCTAssert(CartUseCaseTests.realm.objects(RMCart.self).isEmpty)
        XCTAssert(container.values(DS.Pizza.self).isEmpty)
        XCTAssert(container.values(DS.Cart.self).isEmpty)

        expectation { expectation in
            _ = service.items()
                .first()
                .sink(receiveValue: {
                    XCTAssert($0.isEmpty)
                    expectation.fulfill()
                })
        }

        expectation { expectation in
            _ = service.total()
                .first()
                .sink(receiveCompletion: {
                    switch $0 {
                    case .finished:
                        DLog("finished.")
                        expectation.fulfill()
                    case let .failure(error):
                        XCTAssert(false, "\(error)")
                    }
                }, receiveValue: {
                    XCTAssertEqual($0, 0.0)
                })
        }
    }

    private func _pizzaIndexes(_ items: [CartItem]) -> [Int] {
        items.enumerated().compactMap { item -> Int? in
            self.component.pizzas.pizzas.contains(where: { $0.name == item.element.name }) ? item.offset : nil
        }
    }

    private func _drinkIndexes(_ items: [CartItem]) -> [Int] {
        items.enumerated().compactMap { item -> Int? in
            self.component.drinks.contains(where: { $0.name == item.element.name }) ? item.offset : nil
        }
    }
}
