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

enum Section: Hashable {
    case item // , total
}

class CartViewController: UIViewController {
    typealias Item = CartViewModel.Item
    private typealias _DataSource = UITableViewDiffableDataSource<Section, Item>
    private typealias _Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkoutTap: UITapGestureRecognizer!
    @IBOutlet weak var checkoutLabel: UILabel!

    private var _navigator: Navigator!
    private var _viewModel: CartViewModel!
    private var _isAnimating = false
    private lazy var _dataSource = _makeDataSource()
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _isAnimating = true
    }
}

// MARK: - Private

private extension CartViewController {
    var _dataSourceProperty: [Item] {
        get { [] }
        set {
            _applySnapshot(items: newValue, animatingDifferences: _isAnimating)
        }
    }

    func _bind() {
        _applySnapshot(items: [], animatingDifferences: false)
        let rightPublisher = navigationItem.rightBarButtonItem!.cmb.publisher().map { _ in () }.eraseToAnyPublisher()
        let selected = tableView.cmb.itemSelected()
            .compactMap { [unowned self] ip -> Int? in
                guard self.tableView.cellForRow(at: ip) is CartItemTableViewCell else { return nil }
                return ip.row
            }
        let tap = checkoutTap.cmb.event()
        let input = CartViewModel.Input(selected: selected.eraseToAnyPublisher(),
                                        checkout: tap.eraseToAnyPublisher())
        let out = _viewModel.transform(input: input)

        _bag = [
            // Table view.
            out.tableData
                .assign(to: \._dataSourceProperty, on: self),

            // On checkout success.
            out.showSuccess
                .sink { [unowned self] _ in
                    self._navigator.showSuccess()
                },

            // Enable checkout.
            out.canCheckout
                .sink { [unowned self] in
                    self.checkoutTap.isEnabled = $0
                    self.checkoutLabel.alpha = $0 ? 1.0 : 0.5
                },

            // Add drinks.
            rightPublisher
                .sink { [unowned self] in
                    self._navigator.showDrinks()
                },
        ]
    }

    // MARK: UITableViewDiffableDataSource

    private func _makeDataSource() -> _DataSource {
        let dataSource = _DataSource(
            tableView: tableView,
            cellProvider: { tv, ip, item in
                switch item {
                case let .padding(viewModel):
                    return tv.createCell(PaddingTableViewCell.self, viewModel, ip)
                case let .item(viewModel):
                    return tv.createCell(CartItemTableViewCell.self, viewModel, ip)
                case let .total(viewModel):
                    return tv.createCell(CartTotalTableViewCell.self, viewModel, ip)
                }
            })
        return dataSource
    }

    func _applySnapshot(items: [Item], animatingDifferences: Bool = true) {
        var snapshot = _Snapshot()
        snapshot.appendSections([.item])
        snapshot.appendItems(items, toSection: .item)
        _dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}
