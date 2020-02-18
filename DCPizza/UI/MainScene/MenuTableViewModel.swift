//
//  MenuTableViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain
import RxSwift
import RxDataSources
import struct RxCocoa.Driver

struct MenuTableViewModel: ViewModelType {
    struct Input {}
    struct Output {
        let tableData: Driver<[SectionModel]>
    }

    func transform(input: MenuTableViewModel.Input) -> MenuTableViewModel.Output {
        let useCase = RepositoryNetworkUseCaseProvider().makeNetworkUseCase()
        let sections = Observable.zip(useCase.getPizzas(), useCase.getIngredients()) { (pizzas: $0, ingredients: $1) }
            .map({ pair -> [SectionModel] in
                let basePrice = pair.pizzas.basePrice
                let vms = pair.pizzas.pizzas.map {
                    MenuCellViewModel(basePrice: basePrice,
                                      pizza: $0,
                                      ingredients: pair.ingredients)
                }
                return [SectionModel(items: vms)]
            })
            .asDriver(onErrorJustReturn: [])
        return Output(tableData: sections)
    }
}

extension MenuTableViewModel {
    struct SectionModel {
        var items: [MenuCellViewModel]
    }
}

extension MenuTableViewModel.SectionModel: SectionModelType {
    typealias Item = MenuCellViewModel

    init(original: MenuTableViewModel.SectionModel, items: [Item]) {
        self.items = items
    }
}
