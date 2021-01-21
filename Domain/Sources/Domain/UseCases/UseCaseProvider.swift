//
//  NetworkUseCaseProvider.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import RxSwift

public protocol UseCaseProvider {
    func makeMenuService() -> MenuUseCase
    func makeIngredientsService(pizza: Observable<Pizza>) -> IngredientsUseCase
    func makeCartService() -> CartUseCase
    func makeDrinksService() -> DrinksUseCase
    func makeSaveService() -> SaveUseCase
}
