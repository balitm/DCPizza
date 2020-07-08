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
import Resolver

final class CartViewModel: ObservableObject {
    enum Item: Identifiable {
        private static let _totalIdOffset = 10000
        private static let _paddingIdOffset = 10001

        case padding(viewModel: PaddingRowViewModel)
        case item(viewModel: CartItemRowViewModel)
        case total(viewModel: CartTotalRowViewModel)

        var id: Int {
            switch self {
            case let .padding(viewModel):
                return Item._paddingIdOffset + Int(viewModel.height)
            case let .item(viewModel):
                return viewModel.id
            case .total:
                return Item._totalIdOffset
            }
        }
    }

    // Input
    @Published var selected = -1

    // Output
    @Published var listData = [Item]()
    @Published var showSuccess = false
    @Published var canCheckout = false

    @Injected private var _service: CartUseCase
    private var _bag = Set<AnyCancellable>()

    init() {
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
