//
//  IngredientsHeaderCellViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/19/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import class UIKit.UIImage

struct IngredientsHeaderCellViewModel {
    let image: UIImage?

    init(image: UIImage?) {
        self.image = image
    }
}
