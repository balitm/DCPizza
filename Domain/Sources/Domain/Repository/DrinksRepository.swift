//
//  DrinksRepository.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/20/20.
//

import Foundation
import RxSwift

struct DrinksRepository: DrinksUseCase {
    private let _data: Initializer

    init(data: Initializer) {
        _data = data
    }

    func drinks() -> Observable<[Drink]> {
        _data.component
            .map {
                (try? $0.get().drinks) ?? []
            }
            .catch { _ in
                Observable<[Drink]>.empty()
            }
            .distinctUntilChanged {
                $0.count == $1.count
            }
    }

    func addToCart(drinkIndex: Int) -> Completable {
        _data.component
            .take(1)
            .map {
                try $0.get().drinks.element(at: drinkIndex)
            }
            .flatMapFirst { [unowned data = _data] in
                data.cartActionCompletable(action: .drink(drink: $0))
                    .andThen(Observable.just(()))
            }
            .ignoreElements()
            .asCompletable()
    }
}
