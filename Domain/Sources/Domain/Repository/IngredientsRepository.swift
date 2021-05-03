//
//  IngredientsRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/16/20.
//

import Foundation
import Combine

struct IngredientsRepository: IngredientsUseCase {
    private let _data: Initializer
    private let _pizza: AnyPublisher<Pizza, Never>
    private let _ingredients = CurrentValueSubject<[IngredientSelection], Never>([])

    init(data: Initializer, pizza: AnyPublisher<Pizza, Never>) {
        _data = data
        _pizza = pizza
    }

    func ingredients(selected: AnyPublisher<Int, Never>) -> AnyPublisher<[IngredientSelection], Never> {
        // Create selections publisher.
        _data.$component
            .tryMap {
                try $0.get().ingredients
            }
            .catch { _ in
                Empty<[Ingredient], Never>()
            }
            .flatMap { [pizza = _pizza] ingredients in
                pizza
                    .first()
                    .map {
                        _createSelecteds($0, ingredients)
                    }
            }
            .subscribe(AnySubscriber(_ingredients))

        // Bind selected event to selections publisher.
        selected
            .flatMap { [unowned ingredients = _ingredients] idx in
                ingredients
                    .first()
                    .map { (idx: idx, selecteds: $0) }
            }
            .map {
                var ings = $0.selecteds
                let item = $0.selecteds[$0.idx]
                ings[$0.idx] = IngredientSelection(ingredient: item.ingredient, isOn: !item.isOn)
                return ings
            }
            .subscribe(AnySubscriber(_ingredients))

        return _ingredients
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func addToCart() -> AnyPublisher<Void, Error> {
        _pizza.zip(_ingredients)
            .map { (pair: (pizza: Pizza, ingredients: [IngredientSelection])) -> Pizza in
                Pizza(copy: pair.pizza, with: pair.ingredients.compactMap { $0.isOn ? $0.ingredient : nil })
            }
            .setFailureType(to: Error.self)
            .flatMap { [unowned data = _data] in
                data.cartHandler.trigger(action: .pizza(pizza: $0))
            }
            .first()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func name() -> AnyPublisher<String, Never> {
        _pizza
            .map {
                $0.ingredients.isEmpty ? "CREATE A PIZZA" : $0.name.uppercased()
            }
            .eraseToAnyPublisher()
    }

    func pizza() -> AnyPublisher<Pizza, Never> {
        _pizza
    }
}

/// Create array of Ingredients with selectcion flag.
private func _createSelecteds(_ pizza: Pizza, _ ingredients: [Ingredient]) -> [IngredientSelection] {
    func isContained(_ ingredient: Ingredient) -> Bool {
        pizza.ingredients.contains { $0.id == ingredient.id }
    }

    let sels = ingredients.map { ing -> IngredientSelection in
        IngredientSelection(ingredient: ing, isOn: isContained(ing))
    }
    return sels
}
