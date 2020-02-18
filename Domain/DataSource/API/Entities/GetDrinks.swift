//
//  GetDrinks.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

extension API {
    typealias DrinksModel = ModelBase<[DS.Drink]>

    class GetDrinks: RequestBase<DrinksModel> {
        required init() {
            super.init()
            mainPath = "https://api.myjson.com/bins/150da7"
            fallbackPath = "http://next.json-generator.com/api/json/get/N1mnOA_oz"
        }
    }
}
