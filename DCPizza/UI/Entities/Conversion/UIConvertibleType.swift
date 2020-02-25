//
//  UIConvertibleType.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 2/22/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

protocol UIConvertibleType {
    associatedtype UIType

    func asUI() -> UIType
}
