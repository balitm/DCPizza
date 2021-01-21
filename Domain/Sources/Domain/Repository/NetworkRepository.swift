//
//  NetworkRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import RxSwift
import class AlamofireImage.Image

protocol NetworkProtocol {
    func getPizzas() -> Observable<DS.Pizzas>
    func getIngredients() -> Observable<[DS.Ingredient]>
    func getDrinks() -> Observable<[DS.Drink]>
    func getImage(url: URL) -> Observable<Image>
    func checkout(cart: DS.Cart) -> Completable
}

extension API {
    struct Network: NetworkProtocol {
        func getPizzas() -> Observable<DS.Pizzas> {
            GetPizzas().rx.perform()
        }

        func getIngredients() -> Observable<[DS.Ingredient]> {
            GetIngredients().rx.perform()
        }

        func getDrinks() -> Observable<[DS.Drink]> {
            GetDrinks().rx.perform()
        }

        func getImage(url: URL) -> Observable<Image> {
            let downloader = API.ImageDownloader(path: url.absoluteString)
            return downloader.rx.perform()
        }

        func checkout(cart: DS.Cart) -> Completable {
            Checkout(pizzas: cart.pizzas, drinks: cart.drinks).rx.perform()
                .ignoreElements()
                .asCompletable()
        }
    }
}
