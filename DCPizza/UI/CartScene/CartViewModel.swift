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

final class CartViewModel: ObservableObject {
    enum Item: Identifiable {
        case padding(viewModel: PaddingRowViewModel)
        case item(viewModel: CartItemRowViewModel)
        case total(viewModel: CartTotalRowViewModel)

        var id: String {
            switch self {
            case let .padding(vm):
                return "\(vm.height)"
            case let .item(viewModel):
                return viewModel.name
            case .total:
                return "total"
            }
        }
    }

    // Input
    @Published var selected = -1

    // Output
    @Published var listData = [Item]()
    @Published var showSuccess = false
    @Published var canCheckout = false

    private let _service: CartUseCase
    private var _bag = Set<AnyCancellable>()

    init(service: CartUseCase) {
        _service = service

        // List data.
        _service.items()
            .zip(_service.total())
            .map({ (pair: (items: [CartItem], total: Double)) -> [Item] in
                var items = [Item.padding(viewModel: PaddingRowViewModel(height: 12))]
                items.append(contentsOf:
                    pair.items.enumerated().map({
                        Item.item(viewModel: CartItemRowViewModel(item: $0.element, index: $0.offset))
                    })
                )
                items.append(.padding(viewModel: PaddingRowViewModel(height: 24)))
                items.append(.total(viewModel: CartTotalRowViewModel(price: pair.total)))
                return items
            })
            .assign(to: \.listData, on: self)
            .store(in: &_bag)

        // Remove item on tap/selected.
        $selected
            .print()
            .filter({ $0 >= 0 })
            .flatMap({ [service = _service] idx -> AnyPublisher<Void, Never> in
                service.remove(at: idx)
                    .catch({ _ in Empty<Void, Never>() })
                    .eraseToAnyPublisher()
            })
            .sink {}
            .store(in: &_bag)

        // Can checkout (cart is not empty).
        _service.items()
            .map({ !$0.isEmpty })
            .assign(to: \.canCheckout, on: self)
            .store(in: &_bag)
    }

    // func transform(input: Input) -> Output {
    //     let checkout = input.checkout
    //         .flatMap({ [service = _service] in
    //             service.checkout()
    //                 .catch({ _ in Empty<Void, Never>() })
    //         })
    // }
}
