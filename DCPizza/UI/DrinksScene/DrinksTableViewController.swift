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

private enum _Section: Hashable {
    case item
}

class DrinksTableViewController: UITableViewController {
    typealias Item = DrinksTableViewModel.Item
    private typealias _DataSource = UITableViewDiffableDataSource<_Section, Item>
    private typealias _Snapshot = NSDiffableDataSourceSnapshot<_Section, Item>

    private var _navigator: Navigator!
    private var _viewModel: DrinksTableViewModel!
    private lazy var _dataSource = _makeDataSource()
    private var _bag = Set<AnyCancellable>()

    class func create(with navigator: Navigator, viewModel: DrinksTableViewModel) -> DrinksTableViewController {
        let vc = navigator.storyboard.load(type: DrinksTableViewController.self)
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
}

private extension DrinksTableViewController {
    var _dataSourceProperty: [Item] {
        get { [] }
        set {
            _applySnapshot(items: newValue, animatingDifferences: false)
        }
    }

    func _bind() {
        _applySnapshot(items: [], animatingDifferences: false)
        let selected = tableView.cmb.itemSelected()
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
            tableView: tableView,
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
