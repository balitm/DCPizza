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

private enum _Section: Hashable {
    case item
}

final class IngredientsViewController: UIViewController {
    typealias Item = IngredientsViewModel.Item
    typealias FooterEvent = IngredientsViewModel.FooterEvent
    private typealias _DataSource = UITableViewDiffableDataSource<_Section, Item>
    private typealias _Snapshot = NSDiffableDataSourceSnapshot<_Section, Item>

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showConstraint: NSLayoutConstraint!
    @IBOutlet weak var hideConstraint: NSLayoutConstraint!
    @IBOutlet weak var addTap: UITapGestureRecognizer!
    @IBOutlet weak var cartLabel: UILabel!

    private var _viewModel: IngredientsViewModel!
    private var _navigator: Navigator!
    private var _connectable: Publishers.MakeConnectable<AnyPublisher<FooterEvent, Never>>?
    private lazy var _dataSource = _makeDataSource()
    private var _isAnimating = false
    private var _bag = Set<AnyCancellable>()

    class func create(with navigator: Navigator, viewModel: IngredientsViewModel) -> IngredientsViewController {
        let vc = navigator.storyboard.load(type: IngredientsViewController.self)
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

        _connectable?
            .connect()
            .store(in: &_bag)

        _isAnimating = true
    }
}

// MARK: - private bind functions

private extension IngredientsViewController {
    var _dataSourceProperty: [Item] {
        get { [] }
        set {
            _applySnapshot(items: newValue, animatingDifferences: _isAnimating)
        }
    }

    func _bind() {
        _applySnapshot(items: [], animatingDifferences: false)
        let out = _viewModel.transform(
            input: IngredientsViewModel.Input(selected: tableView.cmb.itemSelected().map { $0.row }.eraseToAnyPublisher(),
                                              addEvent: addTap.cmb.event().map { _ in () }.eraseToAnyPublisher())
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
                .assign(to: \.text, on: cartLabel),

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
            hideConstraint.priority = UILayoutPriority.defaultLow
            showConstraint.priority = UILayoutPriority.defaultHigh
        case .hide:
            hideConstraint.priority = UILayoutPriority.defaultHigh
            showConstraint.priority = UILayoutPriority.defaultLow
        }
        UIView.animate(withDuration: 0.3, animations: {
            parent.layoutIfNeeded()
        })
    }

    // MARK: UITableViewDiffableDataSource

    private func _makeDataSource() -> _DataSource {
        let dataSource = _DataSource(
            tableView: tableView,
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
