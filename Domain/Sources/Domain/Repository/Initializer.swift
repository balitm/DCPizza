//
//  Initializer.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/12/20.
//

import Foundation
import class AlamofireImage.Image
import RxSwift
import RxRelay

final class Initializer {
    struct Components {
        let pizzas: Pizzas
        let ingredients: [Ingredient]
        let drinks: [Drink]

        static let empty = Components(pizzas: Pizzas(pizzas: [], basePrice: 0), ingredients: [], drinks: [])
    }

    typealias ComponentsResult = Result<Components, Error>

    let container: DS.Container?
    let network: NetworkProtocol

    let cart = BehaviorRelay(value: Cart.empty)
    let component = BehaviorRelay(value: ComponentsResult.failure(API.ErrorType.disabled))

    private let _bag = DisposeBag()
    private typealias _Tuple = (url: URL, index: Int)

    init(container: DS.Container?, network: NetworkProtocol) {
        self.container = container
        self.network = network

        _bag.insert([
            // Get components.
            Observable.zip(network.getPizzas(),
                           network.getIngredients(),
                           network.getDrinks())
                .map { (tuple: (pizzas: DS.Pizzas, ingredients: [DS.Ingredient], drinks: [DS.Drink])) -> ComponentsResult in
                    let ingredients = tuple.ingredients.sorted { $0.name < $1.name }

                    let components = Components(pizzas: tuple.pizzas.asDomain(with: ingredients, drinks: tuple.drinks),
                                                ingredients: ingredients,
                                                drinks: tuple.drinks)
                    return .success(components)
                }
                .catch {
                    Observable.just(.failure($0))
                }
                .bind(to: component),

            // Download pizza images.
            _downloadImages()
                .bind(to: component),

            // Init card.
            component
                .compactMap { try? $0.get() }
                .take(1)
                .map { [weak container] c -> Cart in
                    // DLog("###### init cart. #########")
                    let dsCart = container?.values(DS.Cart.self).first ?? DS.Cart(pizzas: [], drinks: [])
                    var cart = dsCart.asDomain(with: c.ingredients, drinks: c.drinks)
                    cart.basePrice = c.pizzas.basePrice
                    return cart
                }
                .bind(to: cart),
        ])
    }

    private func _downloadImages() -> Observable<ComponentsResult> {
        Observable<ComponentsResult>.create { [unowned self] observer in
            var firstComponent: Components!

            return self.component
                .compactMap { try? $0.get() }
                .take(1)
                .do(onNext: {
                    firstComponent = $0
                })
                .flatMap { component -> Observable<_Tuple> in
                    let urls = component.pizzas.pizzas.enumerated().compactMap { pair -> _Tuple? in
                        guard let url = pair.element.imageUrl else { return nil }
                        return (url, pair.offset)
                    }

                    return Observable.from(urls)
                }
                .flatMap { tuple in
                    self.network.getImage(url: tuple.url)
                        .map { $0 as Image? }
                        .catch { _ in Observable.just(nil) }
                        .map { (image: $0, index: tuple.index) }
                }
                .map { tuple -> ComponentsResult in
                    let index = tuple.index
                    let image = tuple.image
                    let pizza = firstComponent.pizzas.pizzas[index]
                    var pizzas = firstComponent.pizzas.pizzas
                    pizzas[index] = Pizza(copy: pizza, image: image)
                    let all = Pizzas(pizzas: pizzas, basePrice: firstComponent.pizzas.basePrice)
                    let components = Components(pizzas: all,
                                                ingredients: firstComponent.ingredients,
                                                drinks: firstComponent.drinks)
                    firstComponent = components
                    return ComponentsResult.success(components)
                }
                .do(onNext: {
                    let noi = (try? $0.get())?.pizzas.pizzas.reduce(0) {
                        $0 + ($1.image == nil ? 0 : 1)
                    }
                    DLog("number of images: ", noi ?? -1)
                    observer.onNext($0)
                })
                .subscribe()
        }
    }
}
