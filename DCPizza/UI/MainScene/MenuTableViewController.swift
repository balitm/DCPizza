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
    typealias SectionModel = MenuCellViewModel
//    typealias Selected = MenuTableViewModel.Selected

    private var _viewModel: MenuTableViewModel!
    private var _navigator: Navigator!
    private let _saveCart = PassthroughSubject<Void, Error>()
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

    /// Save the current cart.
    func saveCart() {
        _saveCart.send(())
    }

    // MARK: - bind functions

    private func _bind() {
//        let selected = tableView.rx.itemSelected
//            .filterMap({ [unowned self] ip -> FilterMap<Selected> in
//                guard let cell = self.tableView.cellForRow(at: ip) as? MenuTableViewCell else { return .ignore }
//                return .map((ip.row, cell.pizzaView.image))
//            })

        let out = _viewModel.transform(input: MenuTableViewModel.Input(
//             selected: selected,
//             scratch: navigationItem.rightBarButtonItem!.rx.tap.asObservable(),
            cart: navigationItem.leftBarButtonItem!.cmb.publisher().map { _ in () }.eraseToAnyPublisher()
//             saveCart: _saveCart
        ))

        _bag = [
            out.tableData
                .bind(subscriber: tableView.rowsSubscriber(cellIdentifier: "MenuTableViewCell", cellType: MenuTableViewCell.self, cellConfig: { cell, ip, model in
                    cell.config(with: model)
                })),

            //        // Show ingredients.
            //        out.selection.asObservable()
            //            .flatMap({ [unowned self] in
            //                self._navigator.showIngredients(of: $0.pizza,
            //                                                image: $0.image,
            //                                                ingredients: $0.ingredients,
            //                                                cart: $0.cart)
            //            })
            //            .bind(to: _viewModel.cart)
            //            .disposed(by: _bag)
            //
            //        // Show cart.
            //        out.showCart.asObservable()
            //            .flatMap({ [unowned self] in
            //                self._navigator.showCart($0.cart, drinks: $0.drinks)
            //            })
            //            .bind(to: _viewModel.cart)
            //            .disposed(by: _bag)

            // Show addedd.
            out.showAdded
                .sink(receiveValue: { [unowned self] _ in
                    self._navigator.showAdded()
                }),
        ]
    }
}
