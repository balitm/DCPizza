//
//  PassthroughRelay.swift
//  Domain
//
//  Created by Balázs Kilvády on 4/27/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Combine

/// A Subject behaves like PassthroughSubject but never has error or finished Completion.
public final class PassthroughRelay<Output>: RelayBase<PassthroughSubject<Output, Never>> {
    public init() {
        super.init(PassthroughSubject<Output, Never>())
    }
}
