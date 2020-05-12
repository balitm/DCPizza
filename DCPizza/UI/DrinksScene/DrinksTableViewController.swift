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
import CombineDataSources

class DrinksTableViewController: UITableViewController {
    typealias Item = DrinksTableViewModel.Item

    private var _navigator: Navigator!
    private var _viewModel: DrinksTableViewModel!
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

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        _viewModel.cart.send(completion: .finished)
    }

    private func _bind() {
        let selected = tableView.cmb.itemSelected()
            .map({ $0.row })
            .eraseToAnyPublisher()
        let input = DrinksTableViewModel.Input(selected: selected)
        let out = _viewModel.transform(input: input)

        _bag = [
            // Table view.
            out.tableData
                .bind(subscriber: tableView.rowsSubscriber(cellType: DrinkTableViewCell.self, cellConfig: { cell, ip, model in
                    cell.config(with: model)
                })),

            // Show addedd.
            out.showAdded
                .sink(receiveValue: { [weak self] _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self?._navigator.showAdded()
                    }
                }),
        ]
    }
}
