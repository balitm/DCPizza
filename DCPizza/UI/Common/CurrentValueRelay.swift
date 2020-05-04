//
//  CurrentValueRelay.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 5/5/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Combine

final class CurrentValueRelay<Output>: RelayBase<CurrentValueSubject<Output, Never>> {
    init(_ value: Output) {
        super.init(CurrentValueSubject<Output, Never>(value))
    }
}

class RelayBase<Base: Subject>: Subject where Base.Failure == Never {
    typealias Output = Base.Output
    typealias Failure = Base.Failure

    private let _subject: Base

    init(_ subject: Base) {
        _subject = subject
    }

    func send(subscription: Subscription) {
        _subject.send(subscription: subscription)
    }

    func receive<S>(subscriber: S) where Output == S.Input, S.Failure == Never, S: Subscriber {
        _subject.receive(subscriber: subscriber)
    }

    func send(_ input: Output) {
        _subject.send(input)
    }

    func send(completion: Subscribers.Completion<Never>) {
        // _subject.send(completion: completion)
    }
}
