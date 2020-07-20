//
//  NetworkTests.swift
//  Domain
//
//  Created by Balázs Kilvády on 7/20/20.
//

import XCTest
import Resolver
import Combine
@testable import Domain

class NetworkTests: UseCaseTestsBase {
    private var _bag = Set<AnyCancellable>()

    func testDrinks() {
        let service = RepositoryUseCaseProvider(container: container,
                                                network: API.Network()).makeDrinksService()

        expectation(timeout: 5.0) { expectation in
            service.drinks()
                .sink(receiveCompletion: {
                    DLog("completed with ", $0)
                }, receiveValue: {
                    DLog("recved ", $0.count)
                    if !$0.isEmpty {
                        expectation.fulfill()
                    }
                })
                .store(in: &_bag)
        }
    }
}
