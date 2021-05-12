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
import Stevia

private enum _Section: Hashable {
    case item, total
}

class CartViewController: ViewControllerBase {
    typealias Item = CartViewModel.Item
    private typealias _DataSource = UITableViewDiffableDataSource<_Section, Item>
    private typealias _Snapshot = NSDiffableDataSourceSnapshot<_Section, Item>

    private let _tableView = UITableView(frame: CGRect.zero, style: .insetGrouped)
    private let _checkoutView = UIView()
    private let _checkoutLabel = UILabel()

    private let _navigator: Navigator
    private let _viewModel: CartViewModel
    private var _isAnimating = false
    private lazy var _dataSource = _makeDataSource()
    private var _bag = Set<AnyCancellable>()

    init(navigator: Navigator, viewModel: CartViewModel) {
        _navigator = navigator
        _viewModel = viewModel
        super.init()
    }

    // MARK: - View functions

    override func viewDidLoad() {
        super.viewDidLoad()

        _tableView.tableFooterView = UIView()
        _tableView.register(CartItemTableViewCell.self)
        _tableView.register(CartTotalTableViewCell.self)
        _bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _isAnimating = true
    }

    override func setupViews() {
        title = "CART"
        navigationItem.backButtonTitle = " "
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.setRightBarButton(UIBarButtonItem(image: UIImage(named: "ic_drinks"),
                                                         style: .plain,
                                                         target: nil, action: nil),
                                         animated: false)

        _checkoutLabel.style { l in
            l.font = UIFont.boldSystemFont(ofSize: 16)
            l.textColor = UIColor(.price)
            l.text = "CHECKOUT"
        }

        _checkoutView.style { v in
            v.backgroundColor = UIColor(.tint)
        }

        _tableView.backgroundColor = .systemBackground

        // Add views.
        _checkoutView.subviews {
            _checkoutLabel
        }

        view.subviews {
            _tableView
            _checkoutView
        }

        // Layout views.
        _checkoutLabel.centerHorizontally()
        _checkoutLabel.top(16)

        _checkoutView.leading(0).trailing(0).height(90)
        _checkoutView.Top == view.safeAreaLayoutGuide.Bottom - 50

        _tableView.leading(0).trailing(0).top(0)
        _tableView.Bottom == _checkoutView.Top
    }
}

// MARK: - Private

private extension CartViewController {
    var _dataSourceProperty: [[Item]] {
        get { [] }
        set {
            _applySnapshot(items: newValue, animatingDifferences: _isAnimating)
        }
    }

    func _bind() {
        // Fill the table with empty data.
        _applySnapshot(items: [[], []], animatingDifferences: false)

        // Add tap recognizer to checkout.
        let checkoutTap = UITapGestureRecognizer()
        _checkoutView.addGestureRecognizer(checkoutTap)

        let rightPublisher = navigationItem.rightBarButtonItem!.cmb.publisher().map { _ in () }.eraseToAnyPublisher()
        let selected = _tableView.cmb.itemSelected()
            .compactMap { [unowned self] ip -> Int? in
                guard self._tableView.cellForRow(at: ip) is CartItemTableViewCell else { return nil }
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
                    checkoutTap.isEnabled = $0
                    self._checkoutLabel.alpha = $0 ? 1.0 : 0.5
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
            tableView: _tableView,
            cellProvider: { tv, ip, item in
                switch item {
                case let .item(viewModel):
                    return tv.createCell(CartItemTableViewCell.self, viewModel, ip)
                case let .total(viewModel):
                    return tv.createCell(CartTotalTableViewCell.self, viewModel, ip)
                }
            })
        dataSource.defaultRowAnimation = .fade
        return dataSource
    }

    func _applySnapshot(items: [[Item]], animatingDifferences: Bool = true) {
        var snapshot = _Snapshot()
        assert(items.count == 2)
        snapshot.appendSections([.item, .total])
        snapshot.appendItems(items[0], toSection: .item)
        snapshot.appendItems(items[1], toSection: .total)
        // var sections = [Section.total]
        // if !items[0].isEmpty {
        //     sections.insert(.item, at: 0)
        // }
        // snapshot.appendSections(sections)
        // if !items[0].isEmpty {
        //     snapshot.appendItems(items[0], toSection: .item)
        // }
        // snapshot.appendSections(sections)
        // snapshot.appendItems(items[1], toSection: .total)
        _dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}
