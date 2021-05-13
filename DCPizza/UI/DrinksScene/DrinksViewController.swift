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

class DrinksViewController: ViewControllerBase {
    typealias Item = DrinksViewModel.Item
    private typealias _DataSource = UITableViewDiffableDataSource<_Section, Item>
    private typealias _Snapshot = NSDiffableDataSourceSnapshot<_Section, Item>

    private let _tableView = UITableView(frame: CGRect.zero, style: .plain)
    private let _navigator: Navigator
    private let _viewModel: DrinksViewModel
    private lazy var _dataSource = _makeDataSource()
    private var _bag = Set<AnyCancellable>()

    init(navigator: Navigator, viewModel: DrinksViewModel) {
        _navigator = navigator
        _viewModel = viewModel
        super.init()
    }

    // MARK: - View functions

    override func viewDidLoad() {
        super.viewDidLoad()

        _tableView.tableFooterView = UIView()
        _tableView.register(DrinkTableViewCell.self)
        _bind()
    }

    override func setupViews() {
        title = "DRINKS"
        navigationItem.largeTitleDisplayMode = .never
        view.subviews {
            _tableView
        }
        _tableView.fillContainer()
    }
}

private extension DrinksViewController {
    var _dataSourceProperty: [Item] {
        get { [] }
        set {
            _applySnapshot(items: newValue, animatingDifferences: false)
        }
    }

    func _bind() {
        _applySnapshot(items: [], animatingDifferences: false)
        let selected = _tableView.cmb.itemSelected()
            .map { $0.row }
            .eraseToAnyPublisher()
        let input = DrinksViewModel.Input(selected: selected)
        let out = _viewModel.transform(input: input)

        _bag = [
            // Table view.
            out.tableData
                .assign(to: \._dataSourceProperty, on: self),

            // Show addedd.
            out.showAdded
                .sink(receiveValue: { [weak self] index in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self?._navigator.showAdded()
                        self?._tableView.deselectRow(at: IndexPath(row: index, section: 0), animated: true)
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