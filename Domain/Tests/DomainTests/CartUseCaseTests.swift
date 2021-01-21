//
//  CartUseCaseTests.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/17/20.
//

import XCTest
import RxSwift
import RealmSwift
@testable import Domain

class CartUseCaseTests: NetworklessUseCaseTestsBase {
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
        var cart = Cart.empty
        pizzas.forEach {
            cart.add(pizza: $0)
        }
        drinks.forEach {
            cart.add(drink: $0)
        }
        data.cart.accept(cart)
    }

    func testItems() {
        expectation { expectation in
            _ = service.items()
                .subscribe(onNext: {
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
                .subscribe(onCompleted: {
                    DLog("finished.")
                    let cart = self.data.cart.value
                    XCTAssertEqual(cart.pizzas.count, 1)
                    XCTAssertEqual(cart.drinks.count, 2)
                    XCTAssertEqual(cart.pizzas[0].name, self.component.pizzas.pizzas[1].name)
                    expectation.fulfill()
                }, onError: {
                    XCTAssert(false, "\($0)")
                })
        }

        expectation { expectation in
            // Remove the 1st drink.
            _ = service.remove(at: 1)
                .subscribe(onCompleted: {
                    DLog("finished.")
                    let cart = self.data.cart.value
                    XCTAssertEqual(cart.pizzas.count, 1)
                    XCTAssertEqual(cart.drinks.count, 1)
                    XCTAssertEqual(cart.drinks[0].name, self.component.drinks[1].name)
                    expectation.fulfill()
                })
        }
    }

    func testTotoal() {
        var total = 0.0

        expectation { expectation in
            _ = service.total()
                .take(1)
                .withUnretained(self)
                .subscribe(onNext: { owner, amount in
                    let cart = owner.data.cart.value
                    let pp = cart.pizzas.reduce(0.0) {
                        $0 + $1.ingredients.reduce(cart.basePrice) {
                            $0 + $1.price
                        }
                    }
                    let dp = cart.drinks.reduce(0.0) {
                        $0 + $1.price
                    }

                    XCTAssertEqual(amount, pp + dp)
                    total = amount
                }, onError: { error in
                    XCTAssert(false, "\(error)")
                }, onCompleted: {
                    DLog("finished.")
                    expectation.fulfill()
                })
        }

        expectation { expectation in
            _ = service.items()
                .take(1)
                .subscribe(onNext: {
                    let t = $0.reduce(0.0) { $0 + $1.price }
                    XCTAssertEqual(total, t)
                    expectation.fulfill()
                })
        }
    }

    func testCheckout() {
        let data = Initializer(container: container, network: API.Network())
        // data.cart = self.data.cart
        service = CartRepository(data: data)
        var cancellable: Disposable?

        expectation { expectation in
            cancellable = data.component
                .filter {
                    if let c = try? $0.get() {
                        return !c.pizzas.pizzas.isEmpty
                    }
                    return false
                }
                .subscribe(onNext: { _ in
                    expectation.fulfill()
                })
        }
        cancellable?.dispose()

        expectation { expectation in
            cancellable = service.checkout()
                .subscribe(onCompleted: {
                    DLog("finished.")
                    expectation.fulfill()
                }, onError: { error in
                    XCTAssert(false, "\(error)")
                })
        }
        cancellable?.dispose()

        XCTAssert(data.cart.value.pizzas.isEmpty)
        XCTAssert(data.cart.value.drinks.isEmpty)
        XCTAssert(CartUseCaseTests.realm.objects(RMPizza.self).isEmpty)
        XCTAssert(CartUseCaseTests.realm.objects(RMCart.self).isEmpty)
        XCTAssert(container.values(DS.Pizza.self).isEmpty)
        XCTAssert(container.values(DS.Cart.self).isEmpty)

        expectation { expectation in
            _ = service.items()
                .take(1)
                .subscribe(onNext: {
                    XCTAssert($0.isEmpty)
                    expectation.fulfill()
                })
        }

        expectation { expectation in
            _ = service.total()
                .take(1)
                .subscribe(onNext: {
                    XCTAssertEqual($0, 0.0)
                }, onError: { error in
                    XCTAssert(false, "\(error)")
                }, onCompleted: {
                    DLog("finished.")
                    expectation.fulfill()
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
