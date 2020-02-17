//
//  GetIngredients.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

extension API {
    struct IngredientsModel: ModelProtocol {
        typealias Result = [DS.Ingredient]

        init() {}

        func process(json: Data) throws -> [DS.Ingredient] {
            DLog("Recved json data:\n", json)
            return []
        }
    }

    class GetIngredients: RequestBase<IngredientsModel> {
        required init() {
            super.init()
            mainPath = "https://api.myjson.com/bins/ozt3z"
            fallbackPath = "http://next.json-generator.com/api/json/get/EkTFDCdsG"
        }
    }
}
