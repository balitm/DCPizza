//
//  IngredientsTableViewController.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/19/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class IngredientsViewController: UIViewController {
    typealias SectionModel = IngredientsViewModel.SectionModel

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showLayout: NSLayoutConstraint!
    @IBOutlet weak var hideLayout: NSLayoutConstraint!
    @IBOutlet var addTap: UITapGestureRecognizer!
    @IBOutlet weak var cartLabel: UILabel!

    private var _viewModel: IngredientsViewModel!
    private let _bag = DisposeBag()

    class func create(with storyboard: UIStoryboard, viewModel: IngredientsViewModel) -> IngredientsViewController {
        let vc = storyboard.load(type: IngredientsViewController.self)
        vc._viewModel = viewModel
        return vc
    }

    // MARK: - View functions

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()

        _bind()
    }
}

// MARK: - private bind functions

private extension IngredientsViewController {
    func _bind() {
        let out = _viewModel.transform(input: IngredientsViewModel.Input())

        out.title
            .drive(rx.title)
            .dispose()

        _footerTimer()

        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel>(configureCell: { ds, tv, ip, _ in
            switch ds[ip] {
            case let .header(viewModel):
                return tv.createCell(IngredientsHeaderTableViewCell.self, viewModel, ip)
            case let .ingredient(viewModel):
                return tv.createCell(IngredientsItemTableViewCell.self, viewModel, ip)
            }
        })
        out.tableData
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: _bag)

        out.cartText
            .drive(cartLabel.rx.text)
            .disposed(by: _bag)
    }

    func _footerTimer() {
        Observable<Int>.timer(.seconds(3), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                self._hideFooter()
            })
            .disposed(by: _bag)
    }

    func _hideFooter() {
        guard let parent = view else { return }
        parent.layoutIfNeeded()
        hideLayout.priority = UILayoutPriority.defaultHigh
        showLayout.priority = UILayoutPriority.defaultLow
        UIView.animate(withDuration: 0.3, animations: {
            parent.layoutIfNeeded()
        })
    }
}
