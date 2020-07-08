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
    // enum Item: Identifiable {
    //     private static let _totalIdOffset = 10000
    //     private static let _paddingIdOffset = 10001
    //
    //     case padding(viewModel: PaddingRowViewModel)
    //     case item(viewModel: CartItemRowViewModel)
    //     case total(viewModel: CartTotalRowViewModel)
    //
    //     var id: Int {
    //         switch self {
    //         case let .padding(viewModel):
    //             return Item._paddingIdOffset + Int(viewModel.height)
    //         case let .item(viewModel):
    //             return viewModel.id
    //         case .total:
    //             return Item._totalIdOffset
    //         }
    //     }
    // }

    // Input
    @Published var selected = -1

    // Output
    @Published var listData = [CartItemRowViewModel]()
    @Published var totalData = CartTotalRowViewModel(price: 0)
    @Published var showSuccess = false
    @Published var canCheckout = false

    private let _service: CartUseCase
    private var _bag = Set<AnyCancellable>()

    init(service: CartUseCase) {
        _service = service

        // List data.
        _service.items()
            .map({ (items: [CartItem]) -> [CartItemRowViewModel] in
                items.enumerated().map({
                    CartItemRowViewModel(item: $0.element, index: $0.offset)
                })
            })
            .assign(to: \.listData, on: self)
            .store(in: &_bag)

        _service.total()
            .map({
                CartTotalRowViewModel(price: $0)
            })
            .assign(to: \.totalData, on: self)
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

    func checkout() {
        _service.checkout()
            .catch({ error -> Empty<Void, Never> in
                DLog("recved error: ", error)
                return Empty<Void, Never>()
            })
            .map({ true })
            .assign(to: \.showSuccess, on: self)
            .store(in: &_bag)
    }
}

extension CartItemRowViewModel: Identifiable {}
