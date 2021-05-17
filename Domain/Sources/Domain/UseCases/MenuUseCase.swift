//
//  MenuUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/14/20.
//

import Foundation
import Combine

public protocol MenuUseCase {
    /// Request to fetch a pizza image.
    var imageInfo: AnySubscriber<ImageInfo, Never> { get }

    /// DataSource of available pizzas.
    func pizzas() -> AnyPublisher<PizzasResult, Never>

    /// Add a pizza to the shopping cart.
    func addToCart(pizza: Pizza) -> AnyPublisher<Void, Error>
}
