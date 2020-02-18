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

class DomainTests: XCTestCase {
    private let _bag = DisposeBag()

    override func setUp() {
    }

    override func tearDown() {
    }

    func testNetwork() {
        let useCase = RepositoryNetworkUseCaseProvider().makeNetworkUseCase()
        useCase.getIngredients()
            .subscribe()
            .disposed(by: _bag)

        useCase.getDrinks()
            .subscribe()
            .disposed(by: _bag)

        useCase.getPizzas()
            .subscribe()
            .disposed(by: _bag)
    }
}
