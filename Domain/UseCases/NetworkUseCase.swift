//
//  NetworkUseCase.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import RxSwift

struct NetworkUseCase {
    func getIngredients() -> Observable<Void> {
        API.GetIngredients().rx.perform()
            .map({ _ in () })
    }
}
