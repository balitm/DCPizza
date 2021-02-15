//
//  CppConvertibleType.swift
//  Domain
//
//  Created by Balázs Kilvády on 02/15/21.
//

import Foundation

protocol CppConvertibleType {
    var _cppObject: OpaquePointer { get }
}
