//
//  IngredientsRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/16/20.
//

import Foundation
import RxSwift
import RxRelay
import class AlamofireImage.Image

struct IngredientsRepository: IngredientsUseCase {
    private let _data: Initializer
    private let _pizza: Observable<Pizza>
    private let _ingredients = BehaviorRelay<[IngredientSelection]>(value: [])
    private let _bag = DisposeBag()

    init(data: Initializer, pizza: Observable<Pizza>) {
        _data = data
        _pizza = pizza
    }

    func ingredients(selected: Observable<Int>) -> Observable<[IngredientSelection]> {
        // Create selections observable.
        _data.component
            .map {
                try $0.get().ingredients
            }
            .catchAndReturn([])
            .flatMapLatest { [unowned pizza = _pizza] ingredients in
                pizza
                    .take(1)
                    .map {
                        _createSelecteds($0, ingredients)
                    }
            }
            .bind(to: _ingredients)
            .disposed(by: _bag)

        // Bind selected event to selections observable.
        Observable.zip(selected, _ingredients) { (idx: $0, selecteds: $1) }
            .map {
                var ings = $0.selecteds
                let item = $0.selecteds[$0.idx]
                ings[$0.idx] = IngredientSelection(ingredient: item.ingredient, isOn: !item.isOn)
                return ings
            }
            .bind(to: _ingredients)
            .disposed(by: _bag)

        return _ingredients.asObservable()
    }

    func addToCart() -> Completable {
        Observable.zip(_pizza, _ingredients)
            .take(1)
            .map { (pair: (pizza: Pizza, ingredients: [IngredientSelection])) -> Pizza in
                Pizza(copy: pair.pizza, with: pair.ingredients.compactMap { $0.isOn ? $0.ingredient : nil })
            }
            .flatMapLatest { [unowned data = _data] in
                data.cartActionCompletable(action: .pizza(pizza: $0))
                    .andThen(Observable.just(()))
            }
            .ignoreElements()
            .asCompletable()
    }

    func name() -> Observable<String> {
        _pizza
            .map {
                $0.ingredients.isEmpty ? "CREATE A PIZZA" : $0.name.uppercased()
            }
    }

    func pizza() -> Observable<Pizza> {
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
