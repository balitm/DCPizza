//
//  UIPizza.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/22/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain

enum UI {}

extension UI {
    struct Pizza {
        let pizza: Domain.Pizza
        let id: Int
    }
}
