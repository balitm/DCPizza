//
//  NetworklessUseCaseTestsBase.swift
//  Domain
//
//  Created by Balázs Kilvády on 7/20/20.
//

import XCTest
import RealmSwift
import RxSwift
@testable import Domain

class NetworklessUseCaseTestsBase: UseCaseTestsBase {
    var data: Initializer!
    var component: Initializer.Components!

    override func setUp() {
        super.setUp()

        let network: NetworkProtocol = TestNetUseCase()
        data = Initializer(container: container, network: network)
        component = try! data.component.value.get()
    }

    func addItemTest(addItem: () -> Completable,
                     test: (Cart) -> Void = { XCTAssertEqual($0.pizzas.count, 1) }) {
        data.cart.accept(Cart.empty)
        XCTAssert(data.cart.value.pizzas.isEmpty)
        XCTAssert(data.cart.value.drinks.isEmpty)
        expectation { expectation in
            _ = addItem()
                .subscribe(onCompleted: {
                    XCTAssert(true)
                }, onError: {
                    XCTAssert(false, "failed with: \($0)")
                }, onDisposed: {
                    expectation.fulfill()
                })
        }
        test(data.cart.value)
    }

    // func addItemTest(addItem: () -> Observable<Void>,
    //                  test: (Cart) -> Void = { XCTAssertEqual($0.pizzas.count, 1) }) {
    //     data.cart.accept(Cart.empty)
    //     XCTAssert(data.cart.value.pizzas.isEmpty)
    //     XCTAssert(data.cart.value.drinks.isEmpty)
    //     expectation { expectation in
    //         _ = addItem()
    //             .subscribe(onNext: {
    //                 XCTAssert(true)
    //             }, onError: {
    //                 XCTAssert(false, "failed with: \($0)")
    //             }, onDisposed: {
    //                 expectation.fulfill()
    //             })
    //     }
    //     test(data.cart.value)
    // }
}
