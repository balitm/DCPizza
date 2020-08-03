//
//  IngredientsItemRowViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 6/21/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

struct IngredientsItemRowViewModel {
    let name: String
    let priceText: String
    let isContained: Bool
    let index: Int
}

extension IngredientsItemRowViewModel: Identifiable {
    var id: Int { index }
}
