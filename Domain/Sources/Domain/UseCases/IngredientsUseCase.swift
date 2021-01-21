//
//  IngredientsUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/15/20.
//

import Foundation
import RxSwift

public protocol IngredientsUseCase {
    func ingredients(selected: Observable<Int>) -> Observable<[IngredientSelection]>
    func addToCart() -> Completable
    func name() -> Observable<String>
    func pizza() -> Observable<Pizza>
}
