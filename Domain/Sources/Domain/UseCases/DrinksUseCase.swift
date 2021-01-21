//
//  DrinksUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/20/20.
//

import Foundation
import RxSwift

public protocol DrinksUseCase {
    func drinks() -> Observable<[Drink]>
    func addToCart(drinkIndex: Int) -> Completable
}
