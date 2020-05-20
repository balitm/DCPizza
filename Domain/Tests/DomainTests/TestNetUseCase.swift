//
//  TestNetUseCase.swift
//
//
//  Created by Balázs Kilvády on 4/24/20.
//

import Foundation
import Combine
@testable import Domain

struct TestNetUseCase: NetworkProtocol {
    private func _decode<T: Decodable>(_ type: T.Type, _ jsonStr: String) -> AnyPublisher<T, API.ErrorType> {
        do {
            let jsonData = jsonStr.data(using: .utf8)!
            let decoder = JSONDecoder()
            let object = try decoder.decode(T.self, from: jsonData)
            return Result.Publisher(object).eraseToAnyPublisher()
        } catch {
            DLog(">>> decode error: ", error)
        }
        return Empty<T, API.ErrorType>().eraseToAnyPublisher()
    }

    func getIngredients() -> AnyPublisher<[Ingredient], API.ErrorType> {
        let jsonStr = """
        [
            {
                "id": 1,
                "name": "Mozzarella",
                "price": 1
            },
                {
                "id": 2,
                "name": "Tomato Sauce",
                "price": 0.5
            },
                {
                "id": 3,
                "name": "Salami",
                "price": 1.5
            },
                {
                "id": 4,
                "name": "Mushrooms",
                "price": 2
            },
                {
                "id": 5,
                "name": "Ricci",
                "price": 4
            },
                {
                "id": 6,
                "name": "Asparagus",
                "price": 2
            },
                {
                "id": 7,
                "name": "Pineapple",
                "price": 1
            },
                {
                "id": 8,
                "name": "Speck",
                "price": 3
            },
                {
                "id": 9,
                "name": "Bottarga",
                "price": 2.5
            },
                {
                "id": 10,
                "name": "Tuna",
                "price": 2.2
            }
        ]
        """
        return _decode([DS.Ingredient].self, jsonStr)
    }

    func getDrinks() -> AnyPublisher<[DS.Drink], API.ErrorType> {
        let jsonStr = """
        [
            {
                "id": 1,
                "name": "Still Water",
                "price": 1
            },
            {
                "id": 2,
                "name": "Sparkling Water",
                "price": 1.5
            },
            {
                "id": 3,
                "name": "Coke",
                "price": 2.5
            },
            {
                "id": 4,
                "name": "Beer",
                "price": 3
            },
            {
                "id": 5,
                "name": "Red Wine",
                "price": 4
            }
        ]
        """
        return _decode([DS.Drink].self, jsonStr)
    }

    func getPizzas() -> AnyPublisher<DS.Pizzas, API.ErrorType> {
        let jsonStr = """
        {
            "basePrice": 4,
            "pizzas": [
                        {
                    "imageUrl": "https://i.ibb.co/2t4sh8w/margherita.png",
                    "ingredients": [
                        1,
                        2
                    ],
                    "name": "Margherita"
                },
                        {
                    "imageUrl": "https://i.ibb.co/GpyPfSC/ricci.png",
                    "ingredients": [
                        1,
                        5
                    ],
                    "name": "Ricci"
                },
                        {
                    "imageUrl": "https://i.ibb.co/9T8jyLt/boscaiola.png",
                    "ingredients": [
                        1,
                        2,
                        3,
                        4
                    ],
                    "name": "Boscaiola"
                },
                        {
                    "imageUrl": "https://i.ibb.co/XD5kYNd/primavera.png",
                    "ingredients": [
                        1,
                        5,
                        6
                    ],
                    "name": "Primavera"
                },
                        {
                    "imageUrl": "https://i.ibb.co/k5qWjBW/hawaii.png",
                    "ingredients": [
                        1,
                        2,
                        7,
                        8
                    ],
                    "name": "Hawaii"
                },
                        {
                    "ingredients": [
                        1,
                        9,
                        10
                    ],
                    "name": "Mare Bianco"
                },
                        {
                    "imageUrl": "https://i.ibb.co/tM9Hrtz/mari-e-monti.png",
                    "ingredients": [
                        1,
                        2,
                        4,
                        8,
                        9,
                        10
                    ],
                    "name": "Mari e monti"
                },
                        {
                    "imageUrl": "https://i.ibb.co/nzmhrbs/bottarga.png",
                    "ingredients": [
                        1,
                        9
                    ],
                    "name": "Bottarga"
                },
                        {
                    "imageUrl": "https://i.ibb.co/FH6MGxT/bottarga-e-asparagus.png",
                    "ingredients": [
                        1,
                        2,
                        9,
                        6
                    ],
                    "name": "Boottarga e Asparagi"
                },
                        {
                    "imageUrl": "https://i.ibb.co/KX0FG9V/ricci-asparagus.png",
                    "ingredients": [
                        1,
                        5,
                        6
                    ],
                    "name": "Ricci e Asparagi"
                }
            ]
        }
        """
        return _decode(DS.Pizzas.self, jsonStr)
    }

    func checkout(cart: DS.Cart) -> AnyPublisher<Void, API.ErrorType> {
        Result.Publisher(()).eraseToAnyPublisher()
    }
}
