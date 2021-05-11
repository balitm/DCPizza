//
//  DrinksTableViewController.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/22/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Domain
import Combine
import Stevia

private enum _Section: Hashable {
    case item
}

class DrinksTableViewController: ViewControllerBase {
    typealias Item = DrinksTableViewModel.Item
    private typealias _DataSource = UITableViewDiffableDataSource<_Section, Item>
    private typealias _Snapshot = NSDiffableDataSourceSnapshot<_Section, Item>

    private let _tableView = UITableView(frame: CGRect.zero, style: .plain)
    private let _navigator: Navigator
    private let _viewModel: DrinksTableViewModel
    private lazy var _dataSource = _makeDataSource()
    private var _bag = Set<AnyCancellable>()

    init(with navigator: Navigator, viewModel: DrinksTableViewModel) {
        _navigator = navigator
        _viewModel = viewModel
        super.init()
    }

    // MARK: - View functions

    override func viewDidLoad() {
        super.viewDidLoad()

        _tableView.tableFooterView = UIView()
        _tableView.register(DrinkTableViewCell.self, forCellReuseIdentifier: DrinkTableViewCell.kReuseID)
        _bind()
    }

    override func setupViews() {
        view.subviews {
            _tableView
        }
        _tableView.fillContainer()
    }
}

private extension DrinksTableViewController {
    var _dataSourceProperty: [Item] {
        get { [] }
        set {
            _applySnapshot(items: newValue, animatingDifferences: false)
        }
    }

    func _bind() {
        title = "DRINKS"
        _applySnapshot(items: [], animatingDifferences: false)
        let selected = _tableView.cmb.itemSelected()
            .map { $0.row }
            .eraseToAnyPublisher()
        let input = DrinksTableViewModel.Input(selected: selected)
        let out = _viewModel.transform(input: input)

        _bag = [
            // Table view.
            out.tableData
                .assign(to: \._dataSourceProperty, on: self),

            // Show addedd.
            out.showAdded
                .sink(receiveValue: { [weak self] _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self?._navigator.showAdded()
                    }
                }),
        ]
    }

    // MARK: UITableViewDiffableDataSource

    private func _makeDataSource() -> _DataSource {
        let dataSource = _DataSource(
            tableView: _tableView,
            cellProvider: { tv, ip, item in
                tv.createCell(DrinkTableViewCell.self, item, ip)
            })
        return dataSource
    }

    func _applySnapshot(items: [Item], animatingDifferences: Bool = true) {
        var snapshot = _Snapshot()
        snapshot.appendSections([.item])
        snapshot.appendItems(items)
        _dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}
