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
        Observable.zip(useCase.getPizzas(), useCase.getIngredients())
            .map({
                
            })
        let items = [SectionItem]()
        return Output(tableData: Driver.just([SectionModel(items: items)]))
    }
}

extension MenuTableViewModel {
    struct SectionModel {
        var items: [SectionItem]
    }

    struct SectionItem {
        let viewModel: MenuCellViewModel
    }
}

extension MenuTableViewModel.SectionModel: SectionModelType {
    typealias Item = MenuTableViewModel.SectionItem

    init(original: MenuTableViewModel.SectionModel, items: [Item]) {
        self.items = items
    }
}
