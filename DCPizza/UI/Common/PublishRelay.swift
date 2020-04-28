//
//  PublishRelay.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 4/27/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Combine

class PublishRelay<Output>: Subject {
    typealias Failure = Never

    private let _subject: PassthroughSubject<Output, Never>

    init() {
        _subject = PassthroughSubject<Output, Never>()
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
