//
//  AppDependencyContainer.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/28/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import SwiftUI
import Combine
import Domain

class AppDependencyContainer {
    let drinksService: DrinksUseCase
    let provider: UseCaseProvider

    init() {
        provider = RepositoryUseCaseProvider()
        drinksService = provider.makeDrinksService()
    }

    func makeCartViewModel() -> CartViewModel {
        CartViewModel(service: provider.makeCartService())
    }

    func makeDrinksTableViewModel() -> DrinksTableViewModel {
        DrinksTableViewModel(service: drinksService)
    }
}
