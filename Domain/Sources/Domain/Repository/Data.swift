//
//  Data.swift
//  Domain
//
//  Created by Balázs Kilvády on 6/8/20.
//

import Foundation

public enum PizzaData {
    static let dsDrinks: [DS.Drink] = load(_kDrinks)
    static let dsIngredients: [DS.Ingredient] = load(_kIngredients)
    static let dsPizzas: DS.Pizzas = load(_kPizzas)
    public static let drinks: [Drink] = {
        dsDrinks.map { $0.asDomain() }
    }()

    public static let ingredients: [Ingredient] = {
        dsIngredients
    }()

    public static var pizzas: Pizzas {
        dsPizzas.asDomain(with: ingredients, drinks: drinks)
    }
}

func load<T: Decodable>(_ jsonStr: String) -> T {
    do {
        let jsonData = jsonStr.data(using: .utf8)!
        let decoder = JSONDecoder()
        let object = try decoder.decode(T.self, from: jsonData)
        return object
    } catch {
        fatalError(">>> decode error: \(jsonStr)\n\(error)")
    }
}

private let _kDrinks = """
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

private let _kIngredients = """
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

private let _kPizzas = """
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
