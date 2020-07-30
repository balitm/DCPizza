//
//  DrinkCellViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/22/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

struct DrinkRowViewModel {
    let name: String
    let priceText: String
    let index: Int
}

extension DrinkRowViewModel: Identifiable {
    var id: Int { index }
}
