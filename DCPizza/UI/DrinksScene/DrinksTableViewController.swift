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
import RxDataSources

class DrinksTableViewController: UITableViewController {
    typealias SectionModel = DrinksTableViewModel.SectionModel

    private var _navigator: Navigator!
    private var _viewModel: DrinksTableViewModel!
    private let _bag = DisposeBag()

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

        rx.viewWillDisappear
            .subscribe(onNext: { [unowned self] _ in
                self._viewModel.cart.on(.completed)
            })
            .disposed(by: _bag)

        _bind()
    }

    private func _bind() {
        let selected = tableView.rx.itemSelected
            .map({ $0.row })
        let input = DrinksTableViewModel.Input(selected: selected)
        let out = _viewModel.transform(input: input)

        // Table view.
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel>(
            configureCell: { ds, tv, ip, _ in
                tv.createCell(DrinkTableViewCell.self, ds[ip], ip)
            }
        )
        out.tableData
            // .debug(trimOutput: true)
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: _bag)

        // Show addedd.
        out.showAdded
            .debug()
            .drive(onNext: { [unowned self] _ in
                self._navigator.showAdded()
            })
            .disposed(by: _bag)
    }
}
