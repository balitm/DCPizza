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

class DomainTests: XCTestCase {
    private var _bag = Set<AnyCancellable>()
    var initData: InitData!
    var useCase: NetworkUseCase!
    var testCart: Cart!
    static var realm: Realm!
    private var _container: DS.Container?

    override class func setUp() {
        super.setUp()

        var _realmConfig: Realm.Configuration {
            var config = Realm.Configuration.defaultConfiguration
            DLog("Realm file: \(config.fileURL!.path)")
            var fileURL = config.fileURL!
            fileURL.deleteLastPathComponent()
            fileURL.deleteLastPathComponent()
            fileURL.appendPathComponent("tmp")
            fileURL.appendPathComponent("test.realm")
            DLog("Realm file: \(fileURL.path)")
            config.fileURL = fileURL
            return config
        }

        do {
            let config = _realmConfig
            realm = try Realm.init(configuration: config)
        } catch {
            fatalError("test realm can't be inited:\n\(error)")
        }
    }

    override func setUp() {
        super.setUp()

        _container = DS.Container(realm: DomainTests.realm)
        useCase = TestNetUseCase()
        useCase.getInitData()
            .sink(receiveCompletion: {
                DLog("received: ", $0)
            }, receiveValue: { [unowned self] in
                self.initData = $0
                guard $0.drinks.count >= 2 && $0.pizzas.pizzas.count >= 2 else { return }
                let pizzas = [
                    $0.pizzas.pizzas[0],
                    $0.pizzas.pizzas[1],
                ]
                let drinks = [
                    $0.drinks[0],
                    $0.drinks[1],
                ]
                self.testCart = Cart(pizzas: pizzas, drinks: drinks, basePrice: $0.pizzas.basePrice)
            })
            .store(in: &_bag)
    }

    override func tearDown() {
        DLog("cancellables: ", _bag.count)
    }

    func testNetwork() {
        let useCase = RepositoryUseCaseProvider(container: _container).makeNetworkUseCase()
        let expectation = XCTestExpectation(description: "net")

        Publishers.Zip(
            useCase.getIngredients(),
            useCase.getDrinks()
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

        let cancellable = Publishers.Zip(API.GetIngredients().cmb.perform(),
                                         API.GetDrinks().cmb.perform())
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
        let pizzas = initData.pizzas
        let dsPizzas = pizzas.asDataSource()
        let isConverted =
            dsPizzas.pizzas.count == pizzas.pizzas.count
            && dsPizzas.pizzas.reduce(true, { r0, pizza in
                r0 && pizza.ingredients.reduce(true, { r1, id in
                    r1 && initData.ingredients.contains { $0.id == id }
                })
            })

        XCTAssertTrue(isConverted)
    }

    func testCartConversion() {
        let cart = testCart!

        let converted = cart.asDataSource().asDomain(with: initData.ingredients, drinks: initData.drinks)
        DLog("converted:\n", converted.drinks.map { $0.id }, "\norig:\n", cart.drinks.map { $0.id })
        let isConverted = _isEqual(converted, rhs: cart)
        XCTAssertTrue(isConverted)
    }

    func testCheckout() {
        let useCase = RepositoryUseCaseProvider(container: _container).makeNetworkUseCase()
        let cart = testCart!

        let expectation = XCTestExpectation(description: "checkout")
        useCase.checkout(cart: cart)
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
            try container.write({
                $0.delete(DS.Cart.self)
                $0.delete(DS.Pizza.self)
            })

            // Compare.
            let converted = dCart.asDomain(with: initData.ingredients, drinks: initData.drinks)
            XCTAssertTrue(_isEqual(converted, rhs: testCart))
            return
        } catch {
            DLog(">>> error caught: ", error)
        }
        XCTAssert(false)
    }

    private func _isEqual(_ lhs: Domain.Cart, rhs: Domain.Cart) -> Bool {
        return lhs.pizzas.map({ $0.name }) == rhs.pizzas.map({ $0.name })
            && lhs.drinks.map { $0.id } == rhs.drinks.map { $0.id }

    }
}
