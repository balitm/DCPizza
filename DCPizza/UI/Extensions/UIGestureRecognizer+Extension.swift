//
//  UIGestureRecognizer+Extension.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 5/1/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import UIKit
import Combine
import Domain

// MARK: - Combine selection publisher

extension UIGestureRecognizer: CombineCompatible {}

extension Combinable where Base: UIGestureRecognizer {
    func event() -> GesturePublisher {
        .init(recognizer: base)
    }
}

struct GesturePublisher: Publisher {
    typealias Output = Void
    typealias Failure = Never

    private let _recognizer: UIGestureRecognizer

    init(recognizer: UIGestureRecognizer) {
        _recognizer = recognizer
    }

    func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = _Subscription(
            subscriber: subscriber,
            recognizer: _recognizer
        )
        subscriber.receive(subscription: subscription)
    }
}

private class _Subscription<S: Subscriber>: Subscription where S.Input == GesturePublisher.Output, S.Failure == TableViewSelectPublisher.Failure {
    private var _subscriber: S?

    init(subscriber: S, recognizer: UIGestureRecognizer) {
        _subscriber = subscriber
        recognizer.addTarget(self, action: #selector(_handle(_:)))
    }

//    deinit {
//        DLog("######## deinit ", type(of: self))
//    }

    func request(_ demand: Subscribers.Demand) {}

    func cancel() {
        _subscriber = nil
    }

    @objc private func _handle(_ sender: UIGestureRecognizer) {
        _ = _subscriber?.receive(())
    }
}
