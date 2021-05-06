//
//  Publishers+Assign.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 7/30/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Combine

extension Publisher where Failure == Never {
    func assign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Output>, on root: Root) -> AnyCancellable {
        sink { [weak root] in
            assert(Thread.isMainThread)
            root?[keyPath: keyPath] = $0
        }
    }
}
