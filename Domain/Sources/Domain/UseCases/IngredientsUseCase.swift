//
//  IngredientsUseCase.swift
//
//
//  Created by Balázs Kilvády on 5/15/20.
//

import Foundation
import Combine

public protocol IngredientsUseCase {
    func ingredients() -> AnyPublisher<[Ingredient], Never>
    func add(pizza: Pizza) -> AnyPublisher<Void, Error>
}
