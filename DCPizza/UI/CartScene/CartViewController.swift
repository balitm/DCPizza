//
//  CartViewController.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/20/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Domain
import RxSwift
import RxDataSources

class CartViewController: UIViewController {
    typealias SectionModel = CartViewModel.SectionModel

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkoutTap: UITapGestureRecognizer!

    private var _viewModel: CartViewModel!
    let bag = DisposeBag()

    class func create(with navigator: Navigator, viewModel: CartViewModel) -> CartViewController {
        let vc = navigator.storyboard.load(type: CartViewController.self)
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

private extension CartViewController {
    func _bind() {
        let out = _viewModel.transform(input: CartViewModel.Input())
        let dataSource = RxTableViewSectionedAnimatedDataSource<SectionModel>(configureCell: { ds, tv, ip, _ in
            switch ds[ip] {
            case let .padding(_, viewModel):
                return tv.createCell(PaddingTableViewCell.self, viewModel, ip)
            case let .item(_, viewModel):
                return tv.createCell(CartItemTableViewCell.self, viewModel, ip)
            case let .total(_, viewModel):
                return tv.createCell(CartTotalTableViewCell.self, viewModel, ip)
            }
        })
        out.tableData
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
}
