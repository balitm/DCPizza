//
//  MenuTableViewController.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Domain
import RxSwift
import RxDataSources
import RxCocoa
import Resolver

final class MenuTableViewController: UITableViewController {
    typealias SectionModel = MenuTableViewModel.SectionModel

    @LazyInjected private var _viewModel: MenuTableViewModel
    private var _navigator: Navigator!
    private let _bag = DisposeBag()

    func setup(with navigator: Navigator) {
        _navigator = navigator
    }

    // MARK: - View functions

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .always
        tableView.tableFooterView = UIView()
        tableView.delegate = nil
        tableView.dataSource = nil

        _bind()
    }

    @IBAction func unwindToMenu(_ segue: UIStoryboardSegue) {
        DLog("Unwinded to menu.")
    }

    // MARK: - bind functions

    private func _bind() {
        let leftTap = navigationItem.leftBarButtonItem!.rx.tap
            .map { _ in () }
        let rightTap = navigationItem.rightBarButtonItem!.rx.tap
            .map { _ in () }
        let selected = tableView.rx.itemSelected
            .map { $0.row }

        let out = _viewModel.transform(input: MenuTableViewModel.Input(
            selected: selected,
            scratch: rightTap
        ))

        // Table view.
        let dataSource = RxTableViewSectionedAnimatedDataSource<SectionModel>(
            configureCell: { _, tv, ip, viewModel in
                tv.createCell(MenuTableViewCell.self, viewModel, ip)
            }
        )

        _bag.insert([
            // Table view data source.
            out.tableData
                .drive(tableView.rx.items(dataSource: dataSource)),

            // Show ingredients.
            out.selection
                .drive(onNext: { [unowned self] in
                    self._navigator.showIngredients(of: $0)
                }),

            // Show cart.
            leftTap
                .subscribe(onNext: { [unowned self] in
                    self._navigator.showCart()
                }),

            // Show addedd.
            out.showAdded
                .drive(onNext: { [unowned self] _ in
                    self._navigator.showAdded()
                }),
        ])
    }
}
