//
//  CartUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/16/20.
//

import Foundation
import RxSwift

public protocol CartUseCase {
    func items() -> Observable<[CartItem]>
    func total() -> Observable<Double>
    func remove(at index: Int) -> Completable
    func checkout() -> Completable
}
