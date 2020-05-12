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

extension UIBarButtonItem: CombineCompatible {}

extension Combinable where Base: UIBarButtonItem {
    func publisher() -> BarButtonPublisher {
        .init(item: base)
    }
}

struct BarButtonPublisher: Publisher {
    typealias Output = UIBarButtonItem
    typealias Failure = Never

    private let _item: UIBarButtonItem

    init(item: UIBarButtonItem) {
        _item = item
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = _ItemSubscription(
            subscriber: subscriber,
            item: _item
        )
        subscriber.receive(subscription: subscription)
    }
}

private class _ItemSubscription<S: Subscriber>: Subscription where S.Input == BarButtonPublisher.Output, S.Failure == BarButtonPublisher.Failure {
    private var _subscriber: S?

    init(subscriber: S, item: BarButtonPublisher.Output) {
        _subscriber = subscriber
        item.target = self
        item.action = #selector(_handler)
    }

//    deinit {
//        DLog("######## deinit ", type(of: self))
//    }

    func request(_ demand: Subscribers.Demand) {}

    func cancel() {
        _subscriber = nil
    }

    @objc private func _handler(_ sender: BarButtonPublisher.Output) {
        _ = _subscriber?.receive(sender)
    }
}
