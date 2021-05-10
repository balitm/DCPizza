//
//  UITableView+Extension.swift
//
//  Created by Balázs Kilvády on 1/20/17.
//  Copyright © 2017 Balázs Kilvády. All rights reserved.
//

import UIKit
import Domain
import Combine

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

// MARK: - Combine selection publisher

extension UITableView: CombineCompatible {}

extension Combinable where Base: UITableView {
    func itemSelected() -> TableViewSelectPublisher {
        .init(tableView: base)
    }
}

struct TableViewSelectPublisher: Publisher {
    typealias Output = IndexPath
    typealias Failure = Never

    private let _tableView: UITableView

    init(tableView: UITableView) {
        _tableView = tableView
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = _Subscription(
            subscriber: subscriber,
            tableView: _tableView
        )
        subscriber.receive(subscription: subscription)
    }
}

private class _Subscription<S: Subscriber>: Subscription where S.Input == TableViewSelectPublisher.Output, S.Failure == TableViewSelectPublisher.Failure {
    private var _subscriber: S?
    private let _delegate: _Delegate

    init(subscriber: S, tableView: UITableView) {
        _subscriber = subscriber
        _delegate = _Delegate()
        tableView.delegate = _delegate
        _delegate.config { [weak self] in _ = self?._subscriber?.receive($0) }
    }

//    deinit {
//        DLog("######## deinit ", type(of: self))
//    }

    func request(_ demand: Subscribers.Demand) {}

    func cancel() {
        _subscriber = nil
    }
}

private class _Delegate: NSObject, UITableViewDelegate {
    typealias Select = (IndexPath) -> Void

    var _select: Select?

    func config(selected: @escaping (IndexPath) -> Void) {
        _select = selected
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // DLog("selected: ", indexPath.description)
        _select?(indexPath)
    }
}
