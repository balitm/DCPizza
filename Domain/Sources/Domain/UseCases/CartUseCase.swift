//
//  CartUseCase.swift
//
//
//  Created by Balázs Kilvády on 5/16/20.
//

import Foundation
import Combine

public protocol CartUseCase {
    func items() -> AnyPublisher<[Cart.Item], Never>
    func total() -> AnyPublisher<Double, Never>
    func remove(at index: Int) -> AnyPublisher<Void, Error>
    func checkout() -> AnyPublisher<Void, API.ErrorType>
}
