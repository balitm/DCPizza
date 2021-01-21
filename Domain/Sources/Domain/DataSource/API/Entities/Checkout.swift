//
//  Checkout.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/21/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

extension API {
    struct EmptyModel: Decodable {
        init(from decoder: Decoder) throws {
            DLog("decode checkout's response.")
        }
    }

    class Checkout: RequestBase<EmptyModel> {
        private struct _Checkout: Encodable {
            let pizzas: [DS.Pizza]
            let drinks: [DS.Drink.ID]
        }

        private var _pizzas: [DS.Pizza] = []
        private var _drinks: [DS.Drink.ID] = []

        override var httpParams: [String: Any]? {
            let encoder = JSONEncoder()
            let data = _Checkout(pizzas: _pizzas, drinks: _drinks)

            do {
                let encoded = try encoder.encode(data)
                let map = try JSONSerialization.jsonObject(with: encoded, options: .allowFragments)
                guard let body = map as? [String: Any] else { return [:] }
                return body
            } catch {
                DLog(">>> encode failed with: ", error)
            }
            return [:]
        }

        required init() {
            super.init()
            mainPath = "http://httpbin.org/post"
            fallbackPath = "http://httpbin.org/post"
        }

        convenience init(pizzas: [DS.Pizza], drinks: [DS.Drink.ID]) {
            self.init()
            _pizzas = pizzas
            _drinks = drinks
        }
    }
}
