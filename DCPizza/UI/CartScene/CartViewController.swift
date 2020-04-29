//
//  CartViewController.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Domain
import Combine
import CombineDataSources

class CartViewController: UIViewController {
    typealias Item = CartViewModel.Item

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkoutTap: UITapGestureRecognizer!
    @IBOutlet weak var drinksButton: UIBarButtonItem!
    @IBOutlet weak var checkoutLabel: UILabel!

    private var _navigator: Navigator!
    private var _viewModel: CartViewModel!
    private var _bag = Set<AnyCancellable>()

    class func create(with navigator: Navigator, viewModel: CartViewModel) -> CartViewController {
        let vc = navigator.storyboard.load(type: CartViewController.self)
        vc._navigator = navigator
        vc._viewModel = viewModel
        return vc
    }

    deinit {
        DLog(">>> deinit: ", type(of: self))
    }

    // MARK: - View functions

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        _bind()
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)

        if parent == nil {
            _viewModel.cart.send(completion: .finished)
        }
    }
}

private extension CartViewController {
    func _bind() {
        let selected = tableView.cmb.itemSelected()
            .compactMap({ [unowned self] ip -> Int? in
                guard self.tableView.cellForRow(at: ip) is CartItemTableViewCell else { return nil }
                return ip.row
            })

        let tap = checkoutTap.cmb.event()

        let input = CartViewModel.Input(selected: selected.eraseToAnyPublisher(), // Empty<Int, Never>(completeImmediately: false).eraseToAnyPublisher(),
                                        checkout: tap.eraseToAnyPublisher()) // Empty<Void, Never>(completeImmediately: false).eraseToAnyPublisher())
        let out = _viewModel.transform(input: input)

        let tableController = TableViewItemsController<[[Item]]> { _, tv, ip, item -> UITableViewCell in
            switch item {
            case let .padding(viewModel):
                return tv.createCell(PaddingTableViewCell.self, viewModel, ip)
            case let .item(viewModel):
                return tv.createCell(CartItemTableViewCell.self, viewModel, ip)
            case let .total(viewModel):
                return tv.createCell(CartTotalTableViewCell.self, viewModel, ip)
            }
        }
        _bag = [
            // Table view.
            out.tableData
                .bind(subscriber: tableView.rowsSubscriber(tableController)),

            //        // Add drinks.
            //        drinksButton.rx.tap
            //            .withLatestFrom(out.showDrinks)
            //            .flatMap({ [unowned self] in
            //                self._navigator.showDrinks(cart: $0.cart, drinks: $0.drinks)
            //            })
            //            .bind(to: _viewModel.cart)
            //            .disposed(by: _bag)

            // On checkout success.
            out.showSuccess
                .sink(receiveValue: { [unowned self] _ in
                    self._navigator.showSuccess()
                }),

            // Enable checkout.
            out.canCheckout
                .sink(receiveValue: { [unowned self] in
                    self.checkoutTap.isEnabled = $0
                    self.checkoutLabel.alpha = $0 ? 1.0 : 0.5
                }),
        ]
    }
}