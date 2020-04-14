//
//  RealmMapping.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/23/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

extension DS.Pizza: Persistable {
    init(managedObject: RMPizza) {
        name = managedObject.name
        imageUrl = managedObject.imageUrl
        ingredients = managedObject.ingredients.map { $0 }
    }

    func managedObject() -> RMPizza {
        let object = RMPizza()
        object.name = name
        object.imageUrl = imageUrl ?? ""
        object.ingredients.append(objectsIn: ingredients)
        return object
    }
}

extension DS.Cart: Persistable {
    init(managedObject: RMCart) {
        pizzas = managedObject.pizzas.map { DS.Pizza(managedObject: $0) }
        drinks = managedObject.drinks.map { DS.Drink.ID($0) }
    }

    func managedObject() -> RMCart {
        let object = RMCart()
        let pizzaObjects = pizzas.map { $0.managedObject() }
        object.pizzas.append(objectsIn: pizzaObjects)
        object.drinks.append(objectsIn: drinks)
        return object
    }
}
