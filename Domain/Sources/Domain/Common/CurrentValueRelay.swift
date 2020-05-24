//
//  CurrentValueRelay.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/5/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Combine

/// A Subject behaves like CurrentValueSubject but never has error or finished Completion.
public final class CurrentValueRelay<Output>: RelayBase<CurrentValueSubject<Output, Never>> {
    public init(_ value: Output) {
        super.init(CurrentValueSubject<Output, Never>(value))
    }
}

public class RelayBase<Base: Subject>: Subject where Base.Failure == Never {
    public typealias Output = Base.Output
    public typealias Failure = Base.Failure

    private let _subject: Base

    init(_ subject: Base) {
        _subject = subject
    }

    public func send(subscription: Subscription) {
        _subject.send(subscription: subscription)
    }

    public func receive<S>(subscriber: S) where Output == S.Input, S.Failure == Never, S: Subscriber {
        _subject.receive(subscriber: subscriber)
    }

    public func send(_ input: Output) {
        _subject.send(input)
    }

    public func send(completion: Subscribers.Completion<Never>) {
        // Swallow finished event.
        // _subject.send(completion: completion)
    }
}
