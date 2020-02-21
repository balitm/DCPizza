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
import RxSwiftExt
import RxCocoa
import RxDataSources

final class MenuTableViewController: UITableViewController {
    typealias SectionModel = MenuTableViewModel.SectionModel
    typealias Selected = MenuTableViewModel.Selected

    private lazy var _viewModel: MenuTableViewModel = {
        MenuTableViewModel()
    }()

    private lazy var _navigator: Navigator = {
        DefaultNavigator(storyboard: self.storyboard!, navigationController: self.navigationController!)
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
        let selected = tableView.rx.itemSelected
            .filterMap({ [unowned self] ip -> FilterMap<Selected> in
                guard let cell = self.tableView.cellForRow(at: ip) as? MenuTableViewCell else { return .ignore }
                return .map((ip.row, cell.pizzaView.image))
            })

        let out = _viewModel.transform(input: MenuTableViewModel.Input(selected: selected))

        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel>(configureCell: { ds, tv, ip, _ in
            tv.createCell(MenuTableViewCell.self, ds[ip], ip)
        })

        out.tableData
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: _bag)

        out.selection.asObservable()
            .flatMap({ [unowned self] in
                self._navigator.showIngredients(of: $0.pizza,
                                                image: $0.image,
                                                ingredients: $0.ingredients,
                                                cart: $0.cart)
            })
            .bind(to: _viewModel.cart)
            .disposed(by: _bag)

        out.showAdded
            .drive(onNext: { [unowned self] _ in
                self._navigator.showAdded()
            })
            .disposed(by: _bag)

        navigationItem.leftBarButtonItem?.rx.tap
            .withLatestFrom(_viewModel.cart) { $1 }
            .flatMap({ [unowned self] in
                self._navigator.showCart($0)
            })
            .bind(to: _viewModel.cart)
            .disposed(by: _bag)
    }
}
