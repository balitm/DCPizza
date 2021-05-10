//
//  MenuTableViewController.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Domain
import Combine

private enum _Section: Hashable {
    case item
}

final class MenuTableViewController: UITableViewController {
    typealias Item = MenuTableViewModel.Item
    private typealias _DataSource = UITableViewDiffableDataSource<_Section, Item>
    private typealias _Snapshot = NSDiffableDataSourceSnapshot<_Section, Item>

    private var _viewModel: MenuTableViewModel!
    private var _navigator: Navigator!
    private lazy var _dataSource = _makeDataSource()
    private var _bag = Set<AnyCancellable>()

    func setup(with navigator: Navigator, viewModel: MenuTableViewModel) {
        _navigator = navigator
        _viewModel = viewModel
    }

    // MARK: - View functions

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()

        DLog("dataSource: ", tableView.dataSource?.description ?? "nil")
        if tableView.dataSource != nil {
            tableView.dataSource = nil
        }

        _bind()
    }

    @IBAction func unwindToMenu(_ segue: UIStoryboardSegue) {
        DLog("Unwinded to menu.")
    }
}

// MARK: - Private

private extension MenuTableViewController {
    var _dataSourceProperty: [Item] {
        get { [] }
        set {
            _applySnapshot(items: newValue, animatingDifferences: true)
        }
    }

    func _bind() {
        _applySnapshot(items: [], animatingDifferences: false)
        let leftPublisher = navigationItem.leftBarButtonItem!.cmb.publisher()
            .map { _ in () }
            .eraseToAnyPublisher()
        let rightPublisher = navigationItem.rightBarButtonItem!.cmb.publisher()
            .map { _ in () }
            .eraseToAnyPublisher()
        let selected = tableView.cmb.itemSelected()
            .map { $0.row }
            .eraseToAnyPublisher()

        let out = _viewModel.transform(input: MenuTableViewModel.Input(
            selected: selected,
            scratch: rightPublisher
        ))

        _bag = [
            // Table view data source.
            out.tableData
                .assign(to: \._dataSourceProperty, on: self),

            // Show ingredients.
            out.selection
                .sink { [unowned self] in
                    _ = self._navigator.showIngredients(of: $0)
                },

            // Show cart.
            leftPublisher
                .sink { [unowned self] in
                    self._navigator.showCart()
                },

            // Show addedd.
            out.showAdded
                .sink { [unowned self] _ in
                    self._navigator.showAdded()
                },
        ]
    }

    // MARK: UITableViewDiffableDataSource

    private func _makeDataSource() -> _DataSource {
        let dataSource = _DataSource(
            tableView: tableView,
            cellProvider: { tv, ip, item in
                tv.createCell(MenuTableViewCell.self, item, ip)
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
