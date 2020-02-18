//
//  GetPizzas.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

extension DS.Pizzas: EntityModel {}

extension API {
    typealias PizzasModel = ModelBase<DS.Pizzas>

    class GetPizzas: RequestBase<PizzasModel> {
        required init() {
            super.init()
            mainPath = "https://api.myjson.com/bins/dokm7"
            fallbackPath = "http://next.json-generator.com/api/json/get/NybelGcjz"
        }
    }
}
