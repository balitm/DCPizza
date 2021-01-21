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
import CombineDataSources

final class MenuTableViewController: UITableViewController {
    private var _viewModel: MenuTableViewModel!
    private var _navigator: Navigator!
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

    // MARK: - bind functions

    private func _bind() {
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

        let tableController = TableViewItemsController<[[MenuCellViewModel]]>(MenuTableViewCell.self)
        tableController.rowAnimations = (
            insert: UITableView.RowAnimation.fade,
            update: UITableView.RowAnimation.fade,
            delete: UITableView.RowAnimation.none
        )

        _bag = [
            // Table view data source.
            out.tableData
                .bind(subscriber: tableView.rowsSubscriber(tableController)),

            // Show ingredients.
            out.selection
                .sink(receiveValue: { [unowned self] in
                    _ = self._navigator.showIngredients(of: $0)
                }),

            // Show cart.
            leftPublisher
                .sink(receiveValue: { [unowned self] in
                    self._navigator.showCart()
                }),

            // Show addedd.
            out.showAdded
                .sink(receiveValue: { [unowned self] _ in
                    self._navigator.showAdded()
                }),
        ]
    }
}
