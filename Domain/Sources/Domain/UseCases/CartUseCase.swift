//
//  CartUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/16/20.
//

import Foundation
import Combine

public protocol CartUseCase {
    func items() -> AnyPublisher<[CartItem], Never>
    func total() -> AnyPublisher<Double, Never>
    func remove(at index: Int) -> AnyPublisher<Void, Error>
    func checkout() -> AnyPublisher<Void, API.ErrorType>
}
