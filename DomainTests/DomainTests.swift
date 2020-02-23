//
//  DomainTests.swift
//  DomainTests
//
//  Created by Balázs Kilvády on 2/17/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import XCTest
import RxSwift
@testable import Domain

private struct _TestNetUseCase: NetworkUseCase {
    private func _decode<T: Decodable>(_ type: T.Type, _ jsonStr: String) -> Observable<T> {
        do {
            let jsonData = jsonStr.data(using: .utf8)!
            let decoder = JSONDecoder()
            let object = try decoder.decode(T.self, from: jsonData)
            return Observable<T>.just(object)
        } catch {
            DLog(">>> decode error: ", error)
        }
        return Observable<T>.empty()
    }

    func getIngredients() -> Observable<[Ingredient]> {
        let jsonStr = """
        [
            {
                "id": 1,
                "name": "Mozzarella",
                "price": 1,
            },
                {
                "id": 2,
                "name": "Tomato Sauce",
                "price": 0.5,
            },
                {
                "id": 3,
                "name": "Salami",
                "price": 1.5,
            },
                {
                "id": 4,
                "name": "Mushrooms",
                "price": 2,
            },
                {
                "id": 5,
                "name": "Ricci",
                "price": 4,
            },
                {
                "id": 6,
                "name": "Asparagus",
                "price": 2,
            },
                {
                "id": 7,
                "name": "Pineapple",
                "price": 1,
            },
                {
                "id": 8,
                "name": "Speck",
                "price": 3,
            },
                {
                "id": 9,
                "name": "Bottarga",
                "price": 2.5,
            },
                {
                "id": 10,
                "name": "Tuna",
                "price": 2.2,
            }
        ]
        """
        return _decode([DS.Ingredient].self, jsonStr)
    }

    func getDrinks() -> Observable<[DS.Drink]> {
        let jsonStr = """
        [
            {
                "id": 1,
                "name": "Still Water",
                "price": 1
            },
            {
                "id": 2,
                "name": "Sparkling Water",
                "price": 1.5
            },
            {
                "id": 3,
                "name": "Coke",
                "price": 2.5
            },
            {
                "id": 4,
                "name": "Beer",
                "price": 3
            },
            {
                "id": 5,
                "name": "Red Wine",
                "price": 4
            }
        ]
        """
        return _decode([DS.Drink].self, jsonStr)
    }

    func getPizzas() -> Observable<DS.Pizzas> {
        let jsonStr = """
        {
            "basePrice": 4,
            "pizzas": [
                        {
                    "imageUrl": "https://i.ibb.co/2t4sh8w/margherita.png",
                    "ingredients": [
                        1,
                        2
                    ],
                    "name": "Margherita",
                },
                        {
                    "imageUrl": "https://i.ibb.co/GpyPfSC/ricci.png",
                    "ingredients": [
                        1,
                        5
                    ],
                    "name": "Ricci",
                },
                        {
                    "imageUrl": "https://i.ibb.co/9T8jyLt/boscaiola.png",
                    "ingredients": [
                        1,
                        2,
                        3,
                        4
                    ],
                    "name": "Boscaiola",
                },
                        {
                    "imageUrl": "https://i.ibb.co/XD5kYNd/primavera.png",
                    "ingredients": [
                        1,
                        5,
                        6
                    ],
                    "name": "Primavera",
                },
                        {
                    "imageUrl": "https://i.ibb.co/k5qWjBW/hawaii.png",
                    "ingredients": [
                        1,
                        2,
                        7,
                        8
                    ],
                    "name": "Hawaii",
                },
                        {
                    "ingredients": [
                        1,
                        9,
                        10
                    ],
                    "name": "Mare Bianco",
                },
                        {
                    "imageUrl": "https://i.ibb.co/tM9Hrtz/mari-e-monti.png",
                    "ingredients": [
                        1,
                        2,
                        4,
                        8,
                        9,
                        10
                    ],
                    "name": "Mari e monti",
                },
                        {
                    "imageUrl": "https://i.ibb.co/nzmhrbs/bottarga.png",
                    "ingredients": [
                        1,
                        9
                    ],
                    "name": "Bottarga",
                },
                        {
                    "imageUrl": "https://i.ibb.co/FH6MGxT/bottarga-e-asparagus.png",
                    "ingredients": [
                        1,
                        2,
                        9,
                        6
                    ],
                    "name": "Boottarga e Asparagi",
                },
                        {
                    "imageUrl": "https://i.ibb.co/KX0FG9V/ricci-asparagus.png",
                    "ingredients": [
                        1,
                        5,
                        6
                    ],
                    "name": "Ricci e Asparagi",
                }
            ]
        }
        """
        return _decode(DS.Pizzas.self, jsonStr)
    }

    func getInitData() -> Observable<InitData> {
        let netData = Observable.zip(getPizzas(),
                                     getIngredients(),
                                     getDrinks(),
                                     resultSelector: { (pizzas: $0, ingredients: $1, drinks: $2) })
            .map({ tuple -> InitData in
                let ingredients = tuple.ingredients.sorted { $0.name < $1.name }
                return InitData(pizzas: tuple.pizzas.asDomain(with: ingredients, drinks: tuple.drinks),
                                ingredients: ingredients,
                                drinks: tuple.drinks,
                                cart: Domain.Cart(pizzas: [],
                                                  drinks: [],
                                                  basePrice: tuple.pizzas.basePrice))
            })
        return netData
    }

    func checkout(cart: Cart) -> Observable<Void> {
        return Observable.just(())
    }
}

class DomainTests: XCTestCase {
    private let _bag = DisposeBag()
    var initData: InitData!
    var useCase: NetworkUseCase!

    override func setUp() {
        super.setUp()

        useCase = _TestNetUseCase()
        useCase.getInitData()
            .subscribe(onNext: { [unowned self] in
                self.initData = $0
            })
            .disposed(by: _bag)
    }

    override func tearDown() {}

    func testNetwork() {
        let useCase = RepositoryNetworkUseCaseProvider().makeNetworkUseCase()
        useCase.getIngredients()
            .subscribe()
            .disposed(by: _bag)

        useCase.getDrinks()
            .subscribe()
            .disposed(by: _bag)
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
        guard initData.drinks.count >= 2 && initData.pizzas.pizzas.count >= 2 else { return }
        let pizzas = [
            initData.pizzas.pizzas[0],
            initData.pizzas.pizzas[1],
        ]
        let drinks = [
            initData.drinks[0],
            initData.drinks[1],
        ]
        let cart = Cart(pizzas: pizzas, drinks: drinks, basePrice: initData.pizzas.basePrice)

        let converted = cart.asDataSource().asDomain(with: initData.ingredients, drinks: initData.drinks)
        DLog("converted:\n", converted.drinks.map { $0.id }, "\norig:\n", cart.drinks.map { $0.id })
        let isConverted = converted.pizzas.map({ $0.name }) == cart.pizzas.map({ $0.name })
            && converted.drinks.map { $0.id } == cart.drinks.map { $0.id }

        XCTAssertTrue(isConverted)
    }

    func testCheckout() {
        guard initData.drinks.count >= 2 && initData.pizzas.pizzas.count >= 2 else { return }

        let useCase = RepositoryNetworkUseCaseProvider().makeNetworkUseCase()
        let pizzas = [
            initData.pizzas.pizzas[0],
            initData.pizzas.pizzas[1],
        ]
        let drinks = [
            initData.drinks[0],
            initData.drinks[1],
        ]
        let cart = Cart(pizzas: pizzas, drinks: drinks, basePrice: initData.pizzas.basePrice)

        let expectation = XCTestExpectation(description: "checkout")
        useCase.checkout(cart: cart)
            .subscribe(onNext: { _ in
                DLog("Checkout succeeded.")
                XCTAssert(true)
            }, onError: { _ in
                XCTAssert(false)
            }, onDisposed: {
                expectation.fulfill()
            })
            .disposed(by: _bag)

        wait(for: [expectation], timeout: 30.0)
    }
}
