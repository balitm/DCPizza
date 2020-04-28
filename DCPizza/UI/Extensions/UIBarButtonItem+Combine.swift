//
//  UIBarButtonItem+Combine.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 4/28/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Combine
import Domain

final class BarButtonPublisher: Publisher {
    typealias Output = UIBarButtonItem
    typealias Failure = Never

    private let _object: Output
    private let _subject = PassthroughSubject<Output, Failure>()

    deinit {
        _object.target = nil
        _object.action = nil
    }

    init(item: UIBarButtonItem) {
        _object = item
        item.target = self
        item.action = #selector(_action(_:))
    }

    func receive<S>(subscriber: S) where S: Subscriber, S.Failure == BarButtonPublisher.Failure, S.Input == BarButtonPublisher.Output {
        _subject.subscribe(subscriber)
    }

    @objc private func _action(_ sender: UIBarButtonItem) {
        _subject.send(sender)
    }
}

extension UIBarButtonItem: CombinableCompatible {}

extension Combinable where Base: UIBarButtonItem {
    func publisher() -> BarButtonPublisher {
        .init(item: base)
    }
}
