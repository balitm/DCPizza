//
//  GetPizzas.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

extension API {
    class GetPizzas: RequestBase<DS.Pizzas> {
        required init() {
            super.init()
            mainPath = "https://api.jsonbin.io/b/5e91f1a0cc62be4369c2e408"
            fallbackPath = "http://next.json-generator.com/api/json/get/NybelGcjz"
        }
    }
}
