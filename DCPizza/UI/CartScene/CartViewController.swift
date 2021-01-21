//
//  CartViewController.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Domain
import RxSwift
import RxDataSources
import Resolver

class CartViewController: UIViewController {
    typealias SectionModel = CartViewModel.SectionModel

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkoutTap: UITapGestureRecognizer!
    @IBOutlet weak var checkoutLabel: UILabel!

    private var _navigator: Navigator!
    @LazyInjected private var _viewModel: CartViewModel
    private let _bag = DisposeBag()

    class func create(with navigator: Navigator) -> CartViewController {
        let vc = navigator.storyboard.load(type: CartViewController.self)
        vc._navigator = navigator
        return vc
    }

    deinit {
        DLog(">>> deinit: ", type(of: self))
    }

    // MARK: - View functions

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        _bind()
    }
}

private extension CartViewController {
    func _bind() {
        let rightTap = navigationItem.rightBarButtonItem!.rx.tap.map { _ in () }
        let selected = tableView.rx.itemSelected
            .compactMap { [unowned self] ip -> Int? in
                guard self.tableView.cellForRow(at: ip) is CartItemTableViewCell else { return nil }
                return Optional(ip.row)
            }

        let input = CartViewModel.Input(selected: selected,
                                        checkout: checkoutTap.rx.event.map { _ in () })
        let out = _viewModel.transform(input: input)

        // Table view.
        let dataSource = RxTableViewSectionedAnimatedDataSource<SectionModel>(
            // decideViewTransition: { ds, tv, changes in
            //     .animated
            // },
            configureCell: { ds, tv, ip, _ in
                switch ds[ip] {
                case let .padding(viewModel):
                    return tv.createCell(PaddingTableViewCell.self, viewModel, ip)
                case let .item(_, viewModel):
                    return tv.createCell(CartItemTableViewCell.self, viewModel, ip)
                case let .total(viewModel):
                    return tv.createCell(CartTotalTableViewCell.self, viewModel, ip)
                }
            }
        )

        _bag.insert([
            out.tableData
                // .debug(trimOutput: true)
                .drive(tableView.rx.items(dataSource: dataSource)),

            // Add drinks.
            rightTap
                .subscribe(onNext: { [unowned self] in
                    self._navigator.showDrinks()
                }),

            // On checkout success.
            out.showSuccess
                .drive(onNext: { [unowned self] _ in
                    self._navigator.showSuccess()
                }),

            // Enable checkout.
            out.canCheckout
                .drive(onNext: { [unowned self] in
                    self.checkoutTap.isEnabled = $0
                    self.checkoutLabel.alpha = $0 ? 1.0 : 0.5
                }),
        ])
    }
}
