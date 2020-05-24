//
//  IngredientsHeaderCellViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/19/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Combine
import class UIKit.UIImage

final class IngredientsHeaderCellViewModel {
    let image: AnyPublisher<UIImage?, Never>

    private var _cancellable: Cancellable?

    init(image: AnyPublisher<UIImage?, Never>) {
        self.image = image
    }
}

extension IngredientsHeaderCellViewModel: Hashable {
    static func ==(lhs: IngredientsHeaderCellViewModel, rhs: IngredientsHeaderCellViewModel) -> Bool {
        var res = false
        lhs._cancellable = lhs.image.zip(rhs.image)
            .first()
            .sink(receiveValue: {
                res = $0 == $1
            })
        return res
    }

    func hash(into hasher: inout Hasher) {
        var hash = 0
        _cancellable = image
            .first()
            .sink(receiveValue: {
                hash = $0?.hash ?? 0
            })
        hasher.combine(hash)
    }
}
