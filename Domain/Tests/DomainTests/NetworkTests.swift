//
//  NetworkTests.swift
//  Domain
//
//  Created by Balázs Kilvády on 7/20/20.
//

import XCTest
import RxSwift
@testable import Domain

class NetworkTests: UseCaseTestsBase {
    private let _bag = DisposeBag()

    func testDrinks() {
        let service = RepositoryUseCaseProvider(container: container,
                                                network: API.Network()).makeDrinksService()

        expectation(timeout: 5.0) { expectation in
            service.drinks()
                .subscribe(onNext: {
                    DLog("recved ", $0.count)
                    if !$0.isEmpty {
                        expectation.fulfill()
                    }
                }, onCompleted: {
                    DLog("completed")
                })
                .disposed(by: _bag)
        }
    }
}
