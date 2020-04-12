//
//  UITableView+Extension.swift
//
//  Created by Balázs Kilvády on 1/20/17.
//  Copyright © 2017 Balázs Kilvády. All rights reserved.
//

import UIKit

protocol ReuseID {
    static var kReuseID: String { get }
}

extension ReuseID {
    static var kReuseID: String {
        String(describing: Self.self)
    }
}

extension UITableView {
    func dequeue<Cell>(type: Cell.Type, for indexPath: IndexPath) -> Cell where Cell: ReuseID, Cell: UITableViewCell {
        let id = Cell.kReuseID
        let cell = dequeueReusableCell(withIdentifier: id, for: indexPath) as! Cell
        return cell
    }

    func dequeue<Cell>(type: Cell.Type) -> Cell where Cell: ReuseID, Cell: UITableViewCell {
        let cell = dequeueReusableCell(withIdentifier: Cell.kReuseID) as! Cell
        return cell
    }
}

protocol CellViewModelProtocol: AnyObject, ReuseID {
    associatedtype ViewModel

    func config(with viewModel: ViewModel)
}

extension UITableView {
    func createCell<Cell, ViewModel>(_ type: Cell.Type, _ viewModel: ViewModel, _ indexPath: IndexPath) -> Cell
        where Cell: UITableViewCell, Cell: CellViewModelProtocol, Cell.ViewModel == ViewModel {
        let cell = dequeue(type: Cell.self, for: indexPath)
        cell.config(with: viewModel)
        return cell
    }
}
