//
//  TestNetUseCase.swift
//
//
//  Created by Balázs Kilvády on 4/24/20.
//

import Foundation
import RxSwift
import class AlamofireImage.Image

struct TestNetUseCase: NetworkProtocol {
    private func _publish<T: Decodable>(_ data: T) -> Observable<T> {
        Observable.just(data)
    }

    func getIngredients() -> Observable<[Ingredient]> {
        _publish(PizzaData.ingredients)
    }

    func getDrinks() -> Observable<[DS.Drink]> {
        _publish(PizzaData.drinks)
    }

    func getPizzas() -> Observable<DS.Pizzas> {
        _publish(PizzaData.dsPizzas)
    }

    func getImage(url: URL) -> Observable<Image> {
        Observable<Image>.empty()
    }

    func checkout(cart: DS.Cart) -> Completable {
        Completable.empty()
    }
}
