//
//  IngredientsTableViewController.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/19/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Domain
import RxSwift
import RxCocoa
import RxSwiftExt
import RxDataSources

final class IngredientsViewController: UIViewController {
    typealias SectionModel = IngredientsViewModel.SectionModel
    typealias FooterEvent = IngredientsViewModel.FooterEvent

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var showConstraint: NSLayoutConstraint!
    @IBOutlet weak var hideConstraint: NSLayoutConstraint!
    @IBOutlet weak var addTap: UITapGestureRecognizer!
    @IBOutlet weak var cartLabel: UILabel!

    private var _viewModel: IngredientsViewModel!
    private var _navigator: Navigator!
    private let _bag = DisposeBag()

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

        rx.methodInvoked(#selector(willMove(toParent:)))
            .filter({
                if $0[0] is NSNull {
                    return true
                }
                return false
            })
            .subscribe(onNext: { [unowned self] _ in
                self._viewModel.cart.on(.completed)
            })
            .disposed(by: _bag)

        _bind()
    }
}

// MARK: - private bind functions

private extension IngredientsViewController {
    func _bind() {
        let out = _viewModel.transform(
            input: IngredientsViewModel.Input(selected: tableView.rx.itemSelected.map { $0.row },
                                              addEvent: addTap.rx.event.map { _ in () })
        )

        out.title
            .drive(rx.title)
            .dispose()

        let dataSource = RxTableViewSectionedAnimatedDataSource<SectionModel>(configureCell: { ds, tv, ip, _ in
            switch ds[ip] {
            case let .header(viewModel):
                return tv.createCell(IngredientsHeaderTableViewCell.self, viewModel, ip)
            case let .ingredient(_, viewModel):
                return tv.createCell(IngredientsItemTableViewCell.self, viewModel, ip)
            }
        })
        out.tableData
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: _bag)

        out.cartText
            .drive(cartLabel.rx.text)
            .disposed(by: _bag)

        out.showAdded
            .drive(onNext: { [unowned self] in
                self._navigator.showAdded()
            })
            .disposed(by: _bag)

        // Pause footer events until view appeared.
        let pauser = rx.viewDidAppear
            .map { _ in true }

        out.footerEvent.asObservable()
            .distinctUntilChanged()
            .pausableBuffered(pauser, limit: 1)
            .bind(to: rx._footer)
            .disposed(by: _bag)
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
}

private extension Reactive where Base: IngredientsViewController {
    /// Bindable sink for `_footer` property.
    var _footer: Binder<IngredientsViewController.FooterEvent> {
        return Binder(base) { vc, event in
            vc._displayFooter(event)
        }
    }
}
