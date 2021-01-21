//
//  SaveRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/21/20.
//

import Foundation
import RxSwift

struct SaveRepository: SaveUseCase {
    private let _data: Initializer

    init(data: Initializer) {
        _data = data
    }

    func saveCart() -> Completable {
        _data.cartActionCompletable(action: .save)
    }
}
