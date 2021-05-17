//
//  IngredientsTableViewController.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/19/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Domain
import Combine
import Stevia

private enum _Section: Hashable {
    case item
}

final class IngredientsViewController: ViewControllerBase {
    typealias Item = IngredientsViewModel.Item
    typealias FooterEvent = IngredientsViewModel.FooterEvent
    private typealias _DataSource = UITableViewDiffableDataSource<_Section, Item>
    private typealias _Snapshot = NSDiffableDataSourceSnapshot<_Section, Item>

    private let _tableView = UITableView(frame: CGRect.zero, style: .plain)
    private let _addTap = UITapGestureRecognizer()
    private var _showConstraint: NSLayoutConstraint!
    private var _hideConstraint: NSLayoutConstraint!
    private let _cartLabel = UILabel()

    private let _viewModel: IngredientsViewModel
    private let _navigator: Navigator
    private var _connectable: Publishers.MakeConnectable<AnyPublisher<FooterEvent, Never>>?
    private lazy var _dataSource = _makeDataSource()
    private var _bag = Set<AnyCancellable>()

    init(navigator: Navigator, viewModel: IngredientsViewModel) {
        _navigator = navigator
        _viewModel = viewModel
        super.init()
    }

    // MARK: - View functions

    override func viewDidLoad() {
        super.viewDidLoad()

        _tableView.tableFooterView = UIView()
        _tableView.register(IngredientsHeaderTableViewCell.self)
        _tableView.register(IngredientsItemTableViewCell.self)
        _bind()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        _connectable?
            .connect()
            .store(in: &_bag)
    }

    override func setupViews() {
        navigationItem.largeTitleDisplayMode = .never
        let addView = UIView()

        // Config views.

        addView.style { v in
            v.backgroundColor = UIColor(.button)
            v.addGestureRecognizer(_addTap)
        }

        _cartLabel.style { l in
            l.textAlignment = .center
            l.textColor = UIColor(.price)
            l.font = UIFont.boldSystemFont(ofSize: 16)
        }

        addView.subviews {
            _cartLabel
        }
        view.subviews {
            _tableView
            addView
        }

        // Layouts.

        _tableView.fillHorizontally()
        _tableView.Top == view.Top
        _tableView.Bottom == addView.Top

        _cartLabel.top(15).fillHorizontally(padding: 16)
        addView.fillHorizontally().height(90)
        _hideConstraint = addView.Top == view.Bottom
        _hideConstraint.priority = UILayoutPriority.defaultHigh
        _showConstraint = addView.Top == view.safeAreaLayoutGuide.Bottom - 50
        _showConstraint.priority = UILayoutPriority.defaultLow
    }
}

// MARK: - private bind functions

private extension IngredientsViewController {
    var _dataSourceProperty: [Item] {
        get { [] }
        set {
            _applySnapshot(items: newValue, animatingDifferences: _hasAppeared)
        }
    }

    func _bind() {
        _applySnapshot(items: [], animatingDifferences: false)
        let out = _viewModel.transform(
            input: IngredientsViewModel.Input(selected: _tableView.cmb.itemSelected().map { $0.row }.eraseToAnyPublisher(),
                                              addEvent: _addTap.cmb.event().map { _ in () }.eraseToAnyPublisher())
        )
        _connectable = out.footerEvent

        let titleCancellable = out.title
            .assign(to: \.title, on: self)

        _bag = [
            // Table view data source.
            out.tableData
                .assign(to: \._dataSourceProperty, on: self),

            // Update the price text on the added view.
            out.cartText
                .assign(to: \.text, on: _cartLabel),

            // Show added confirmation scene.
            out.showAdded
                .sink(receiveValue: { [unowned self] _ in
                    self._navigator.showAdded()
                }),

            // Show or hide the footer.
            out.footerEvent
                .sink(receiveValue: { [unowned self] in
                    self._displayFooter($0)
                }),
        ]

        titleCancellable.cancel()
    }

    func _displayFooter(_ event: FooterEvent) {
        guard let parent = view else { return }
        parent.layoutIfNeeded()
        switch event {
        case .show:
            _hideConstraint.priority = UILayoutPriority.defaultLow
            _showConstraint.priority = UILayoutPriority.defaultHigh
        case .hide:
            _hideConstraint.priority = UILayoutPriority.defaultHigh
            _showConstraint.priority = UILayoutPriority.defaultLow
        }
        UIView.animate(withDuration: 0.3, animations: {
            parent.layoutIfNeeded()
        })
    }

    // MARK: UITableViewDiffableDataSource

    private func _makeDataSource() -> _DataSource {
        let dataSource = _DataSource(
            tableView: _tableView,
            cellProvider: { tv, ip, item in
                switch item {
                case let .header(viewModel):
                    return tv.createCell(IngredientsHeaderTableViewCell.self, viewModel, ip)
                case let .ingredient(viewModel):
                    return tv.createCell(IngredientsItemTableViewCell.self, viewModel, ip)
                }
            })
        dataSource.defaultRowAnimation = .fade
        return dataSource
    }

    func _applySnapshot(items: [Item], animatingDifferences: Bool = true) {
        var snapshot = _Snapshot()
        snapshot.appendSections([.item])
        snapshot.appendItems(items)
        _dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}
