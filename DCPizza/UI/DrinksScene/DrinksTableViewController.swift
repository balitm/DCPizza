//
//  DrinksTableViewController.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/22/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Domain
import RxSwift
import RxCocoa
import Resolver

class DrinksTableViewController: UITableViewController {
    typealias Item = DrinksTableViewModel.Item

    private var _navigator: Navigator!
    @LazyInjected private var _viewModel: DrinksTableViewModel
    private let _bag = DisposeBag()

    class func create(with navigator: Navigator) -> Self {
        let vc = navigator.storyboard.load(type: Self.self)
        vc._navigator = navigator
        return vc
    }

    deinit {
        DLog(">>> deinit: ", type(of: self))
    }

    // MARK: - View functions

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        tableView.delegate = nil
        tableView.dataSource = nil

        _bind()
    }

    private func _bind() {
        let selected = tableView.rx.itemSelected
            .map { $0.row }
        let input = DrinksTableViewModel.Input(selected: selected)
        let out = _viewModel.transform(input: input)

        _bag.insert([
            // Table view.
            out.tableData
                // .debug(trimOutput: true)
                .drive(tableView.rx.items) { tableView, row, viewModel in
                    tableView.createCell(DrinkTableViewCell.self, viewModel, IndexPath(row: row, section: 0))
                },

            // Show addedd.
            out.showAdded
                .drive(onNext: { [weak self] _ in
                    self?._navigator.showAdded()
                }),
        ])
    }
}
