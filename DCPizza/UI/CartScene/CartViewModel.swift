//
//  CartViewModel.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Domain
import Combine

final class CartViewModel: ViewModelType {
    enum Item: Hashable {
        case padding(viewModel: PaddingCellViewModel)
        case item(viewModel: CartItemCellViewModel)
        case total(viewModel: CartTotalCellViewModel)
    }

    struct Input {
        let selected: AnyPublisher<Int, Never>
        let checkout: AnyPublisher<Void, Never>
    }

    struct Output {
        let tableData: AnyPublisher<[Item], Never>
        let showSuccess: AnyPublisher<Void, Never>
        let canCheckout: AnyPublisher<Bool, Never>
    }

    private let _service: CartUseCase
    private var _bag = Set<AnyCancellable>()

    init(service: CartUseCase) {
        _service = service
    }

    func transform(input: Input) -> Output {
        let models = _service.items()
            .zip(_service.total())
            .map({ (pair: (items: [CartItem], total: Double)) -> [Item] in
                var items = [Item.padding(viewModel: PaddingCellViewModel(height: 12))]
                items.append(contentsOf:
                    pair.items.map { Item.item(viewModel: CartItemCellViewModel(item: $0)) }
                )
                items.append(.padding(viewModel: PaddingCellViewModel(height: 24)))
                items.append(.total(viewModel: CartTotalCellViewModel(price: pair.total)))
                return items
            })

        input.selected
            .flatMap({ [service = _service] idx -> AnyPublisher<Void, Never> in
                assert(idx > 0)
                return service.remove(at: idx - 1)
                    .catch({ _ in Empty<Void, Never>() })
                    .eraseToAnyPublisher()
            })
            .sink {}
            .store(in: &_bag)

        let checkout = input.checkout
            .flatMap({ [service = _service] in
                service.checkout()
                    .catch({ _ in Empty<Void, Never>() })
            })

        let canCheckout = _service.items()
            .map({ !$0.isEmpty })

        return Output(
            tableData: models.eraseToAnyPublisher(),
            showSuccess: checkout
                .eraseToAnyPublisher(),
            canCheckout: canCheckout.eraseToAnyPublisher()
        )
    }
}
