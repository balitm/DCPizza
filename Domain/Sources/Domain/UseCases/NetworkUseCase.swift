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
    func getIngredients() -> AnyPublisher<[Ingredient], Error>
    func getDrinks() -> AnyPublisher<[Drink], Error>
    func getInitData() -> AnyPublisher<InitData, Error>
    func checkout(cart: Cart) -> AnyPublisher<Void, Error>
}
