//
//  IngredientsRepository.swift
//
//
//  Created by Balázs Kilvády on 5/16/20.
//

import Foundation
import Combine

struct IngredientsRepository: IngredientsUseCase {
    private let _data: Initializer
    private let _pizza: Pizza
    private let _name: String

    init(data: Initializer, pizza: Pizza) {
        _data = data
        _pizza = pizza
        _name = pizza.ingredients.isEmpty ? "CREATE A PIZZA" : pizza.name.uppercased()
    }

    func ingredients(selected: AnyPublisher<Int, Never>) -> AnyPublisher<[IngredientSelection], Never> {
        let subject = CurrentValueSubject<[IngredientSelection], Never>([])

        // Create selections publisher.
        _data.$component
            .tryMap({
                try $0.get().ingredients
            })
            .catch({ _ in
                Empty<[Ingredient], Never>()
            })
            .map({ [pizza = _pizza] in
                _createSelecteds(pizza, $0)
            })
            .subscribe(AnySubscriber(subject))

        // Bind selected event to selections publisher.
        selected
            .flatMap({ idx in
                subject
                    .first()
                    .map({ (idx: idx, selecteds: $0) })
            })
            .map({
                var ings = $0.selecteds
                let item = $0.selecteds[$0.idx]
                ings[$0.idx] = IngredientSelection(ingredient: item.ingredient, isOn: !item.isOn)
                return ings
            })
            .subscribe(AnySubscriber(subject))

        return subject.eraseToAnyPublisher()
    }

    func addToCart() -> AnyPublisher<Void, Error> {
        Publishers.CartActionPublisher(data: _data, action: .pizza(pizza: _pizza))
            .eraseToAnyPublisher()
    }

    func name() -> AnyPublisher<String, Never> {
        Just(_name).eraseToAnyPublisher()
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
