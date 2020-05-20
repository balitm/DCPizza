//
//  DrinksUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/20/20.
//

import Foundation
import Combine

public protocol DrinksUseCase {
    func drinks() -> AnyPublisher<[Drink], Never>
    func addToCart(drinkIndex: Int) -> AnyPublisher<Void, Error>
}
