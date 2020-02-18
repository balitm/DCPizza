//
//  MenuTableViewController.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class MenuTableViewController: UITableViewController {
    typealias SectionModel = MenuTableViewModel.SectionModel

    lazy var _viewModel: MenuTableViewModel = {
        MenuTableViewModel()
    }()

    private let _bag = DisposeBag()

    // MARK: - View functions

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()

        _bind()
    }

    // MARK: - bind functions

    private func _bind() {
        let out = _viewModel.transform(input: MenuTableViewModel.Input())

        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel>(configureCell: { [weak self] ds, tv, ip, _ in
            tv.createCell(MenuTableViewCell.self, ds[ip].viewModel, ip)
        })
        out.tableData
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: _bag)
    }
}
