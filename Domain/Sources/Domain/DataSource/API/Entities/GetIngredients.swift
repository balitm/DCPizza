//
//  GetIngredients.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

extension API {
    typealias IngredientsModel = ModelBase<[DS.Ingredient]>

    class GetIngredients: RequestBase<IngredientsModel> {
        required init() {
            super.init()
            mainPath = "https://api.jsonbin.io/b/5e91eda1172eb64389622c7a"
            fallbackPath = "http://next.json-generator.com/api/json/get/EkTFDCdsG"
        }
    }
}
