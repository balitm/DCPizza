//
//  SaveUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/21/20.
//

import Foundation
import Combine

public protocol SaveUseCase {
    func saveCart() -> AnyPublisher<Void, Error>
}
