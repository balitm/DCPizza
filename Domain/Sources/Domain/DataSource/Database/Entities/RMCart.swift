//
//  RMCart.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/23/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import RealmSwift

final class RMCart: Object {
    let pizzas = List<RMPizza>()
    let drinks = List<Int64>()
}
