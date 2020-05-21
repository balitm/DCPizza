//
//  SaveRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/21/20.
//

import Foundation
import Combine

struct SaveRepository: SaveUseCase {
    private let _data: Initializer

    init(data: Initializer) {
        _data = data
    }

    func saveCart() -> AnyPublisher<Void, Error> {
        Publishers.CartActionPublisher(data: _data, action: .save).eraseToAnyPublisher()
    }
}
