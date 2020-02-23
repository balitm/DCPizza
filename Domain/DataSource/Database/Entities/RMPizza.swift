//
//  RMPizza.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/23/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import RealmSwift

final class RMPizza: Object {
    @objc dynamic var name = ""
    let ingredients = List<Int64>()
    @objc dynamic var imageUrl = ""
}
