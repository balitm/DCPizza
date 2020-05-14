//
//  NetworkUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Combine

public protocol NetworkUseCase {
    func getIngredients() -> AnyPublisher<[Ingredient], API.ErrorType>
    func getDrinks() -> AnyPublisher<[Drink], API.ErrorType>
    func getInitData() -> AnyPublisher<InitData, API.ErrorType>
    func checkout(cart: Cart) -> AnyPublisher<Void, API.ErrorType>
}
