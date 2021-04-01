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
        let cart = Cart(pizzas: pizzas, drinks: drinks, basePrice: 4.0)

        expectation { [unowned data = data!] expectation in
            _ = data.cartHandler.trigger(action: .start(with: cart))
                .sink {
                    if case let Subscribers.Completion.failure(error) = $0 {
                        XCTAssert(false, "\(error)")
                    }
                    expectation.fulfill()
                } receiveValue: {}
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
                ._cart(from: data.cartHandler)
                .sink {
                    switch $0 {
                    case .finished:
                        DLog("finished.")
                        expectation.fulfill()
                    case let .failure(error):
                        XCTAssert(false, "\(error)")
                    }
                } receiveValue: {
                    XCTAssertEqual($0.cart.pizzas.count, 1)
                    XCTAssertEqual($0.cart.drinks.count, 2)
                    XCTAssertEqual($0.cart.pizzas[0].name, self.component.pizzas.pizzas[1].name)
                }
        }

        expectation { expectation in
            // Remove the 1st drink.
            _ = service.remove(at: 1)
                ._cart(from: data.cartHandler)
                .sink {
                    switch $0 {
                    case .finished:
                        DLog("finished.")
                        expectation.fulfill()
                    case let .failure(error):
                        XCTAssert(false, "\(error)")
                    }
                } receiveValue: {
                    XCTAssertEqual($0.cart.pizzas.count, 1)
                    XCTAssertEqual($0.cart.drinks.count, 1)
                    XCTAssertEqual($0.cart.drinks[0].name, self.component.drinks[1].name)
                }
        }
    }

    func testTotoal() {
        var total = 0.0

        expectation { [unowned data = data!] expectation in
            _ = service.total()
                .first()
                .flatMap { total in
                    data.cartHandler.cartResult
                        .first()
                        .map { (cart: $0.cart, total: total) }
                }
                .sink {
                    switch $0 {
                    case .finished:
                        DLog("finished.")
                        expectation.fulfill()
                    case let .failure(error):
                        XCTAssert(false, "\(error)")
                    }
                } receiveValue: { cart, price in
                    let pp = cart.pizzas.reduce(0.0) {
                        $0 + $1.ingredients.reduce(cart.basePrice) {
                            $0 + $1.price
                        }
                    }
                    let dp = cart.drinks.reduce(0.0) {
                        $0 + $1.price
                    }

                    XCTAssertEqual(price, pp + dp)
                    total = price
                }
        }

        expectation { expectation in
            _ = service.items()
                .first()
                .sink {
                    let t = $0.reduce(0.0) { $0 + $1.price }
                    XCTAssertEqual(total, t)
                    expectation.fulfill()
                }
        }
    }

    func testCheckout() {
        let data = Initializer(container: container, network: API.Network())
        service = CartRepository(data: data)
        var cancellable: AnyCancellable?

        // Init the network card.
        expectation { expectation in
            _ = self.data.cartHandler.cartResult
                .first()
                .map(\.cart)
                .flatMap {
                    data.cartHandler.trigger(action: .start(with: $0))
                        .catch { _ in Empty<Void, Never>() }
                }
                .sink {
                    if case let Subscribers.Completion.failure(error) = $0 {
                        XCTAssert(false, "\(error)")
                    }
                    expectation.fulfill()
                } receiveValue: {}
        }

        expectation { expectation in
            cancellable = data.$component
                .filter {
                    if let c = try? $0.get() {
                        return !c.pizzas.pizzas.isEmpty
                    }
                    return false
                }
                .sink { _ in
                    expectation.fulfill()
                }
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

        expectation { expectation in
            _ = data.cartHandler.cartResult
                .first()
                .map(\.cart)
                .sink {
                    XCTAssert($0.pizzas.isEmpty)
                    XCTAssert($0.drinks.isEmpty)
                    expectation.fulfill()
                }
        }

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
                .sink {
                    switch $0 {
                    case .finished:
                        DLog("finished.")
                        expectation.fulfill()
                    case let .failure(error):
                        XCTAssert(false, "\(error)")
                    }
                } receiveValue: {
                    XCTAssertEqual($0, 0.0)
                }
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

private extension Publishers {
    struct _CartPublisher<Upstream: Publisher, T>: Publisher where Upstream.Failure == Error {
        typealias Output = (cart: Cart, pair: T)
        typealias Failure = Upstream.Failure

        let _upstream: Upstream
        let _cartHandler: CartHandler
        let _pair: T

        init(upstream: Upstream, cartHandler: CartHandler, with: T) {
            _upstream = upstream
            _cartHandler = cartHandler
            _pair = with
        }

        func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            _upstream
                .flatMap { _ in
                    _cartHandler.cartResult
                        .first()
                        .map { (cart: $0.cart, pair: _pair) }
                        .mapError { _ in API.ErrorType.processingFailed }
                }
                .subscribe(subscriber)
        }
    }
}

private extension Publisher where Failure == Error {
    func _cart<T>(from cartHandler: CartHandler, with: T) -> Publishers._CartPublisher<Self, T> {
        .init(upstream: self, cartHandler: cartHandler, with: with)
    }

    func _cart(from cartHandler: CartHandler) -> Publishers._CartPublisher<Self, Void> {
        .init(upstream: self, cartHandler: cartHandler, with: ())
    }
}
