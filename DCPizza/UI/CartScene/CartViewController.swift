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
import RxSwiftExt
import RxDataSources

class CartViewController: UIViewController {
    typealias SectionModel = CartViewModel.SectionModel

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkoutTap: UITapGestureRecognizer!
    @IBOutlet weak var drinksButton: UIBarButtonItem!
    @IBOutlet weak var checkoutLabel: UILabel!

    private var _navigator: Navigator!
    private var _viewModel: CartViewModel!
    private let _bag = DisposeBag()

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

        rx.methodInvoked(#selector(willMove(toParent:)))
            .filter({
                if $0[0] is NSNull {
                    return true
                }
                return false
            })
            .subscribe(onNext: { [unowned self] _ in
                self._viewModel.cart.on(.completed)
            })
            .disposed(by: _bag)

        _bind()
    }
}

private extension CartViewController {
    func _bind() {
        let selected = tableView.rx.itemSelected
            .filterMap({ [unowned self] ip -> FilterMap<Int> in
                guard self.tableView.cellForRow(at: ip) is CartItemTableViewCell else { return .ignore }
                return .map(ip.row)
            })

        let input = CartViewModel.Input(selected: selected,
                                        checkout: checkoutTap.rx.event.map { _ in () })
        let out = _viewModel.transform(input: input)

        // Table view.
        let dataSource = RxTableViewSectionedAnimatedDataSource<SectionModel>(
            decideViewTransition: { ds, tv, changes in
                .animated
            },
            configureCell: { ds, tv, ip, _ in
                switch ds[ip] {
                case let .padding(viewModel):
                    return tv.createCell(PaddingTableViewCell.self, viewModel, ip)
                case let .item(viewModel):
                    return tv.createCell(CartItemTableViewCell.self, viewModel, ip)
                case let .total(viewModel):
                    return tv.createCell(CartTotalTableViewCell.self, viewModel, ip)
                }
        })
        out.tableData
            // .debug(trimOutput: true)
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: _bag)

        // Add drinks.
        drinksButton.rx.tap
            .withLatestFrom(out.showDrinks)
            .flatMap({ [unowned self] in
                self._navigator.showDrinks(cart: $0.cart, drinks: $0.drinks)
            })
            .bind(to: _viewModel.cart)
            .disposed(by: _bag)

        // On checkout success.
        out.showSuccess
            .drive(onNext: { [unowned self] _ in
                self._navigator.showSuccess()
            })
            .disposed(by: _bag)

        // Enable checkout.
        out.canCheckout
            .drive(onNext: { [unowned self] in
                self.checkoutTap.isEnabled = $0
                self.checkoutLabel.alpha = $0 ? 1.0 : 0.5
            })
            .disposed(by: _bag)
    }
}
