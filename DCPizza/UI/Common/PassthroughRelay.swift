//
//  PassthroughRelay.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 4/27/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation
import Combine

final class PassthroughRelay<Output>: RelayBase<PassthroughSubject<Output, Never>> {
    init() {
        super.init(PassthroughSubject<Output, Never>())
    }
}
