//
//  SaveUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/21/20.
//

import Foundation
import RxSwift

public protocol SaveUseCase {
    func saveCart() -> Completable
}
