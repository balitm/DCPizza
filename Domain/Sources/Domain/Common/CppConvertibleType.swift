//
//  CppConvertibleType.swift
//  Domain
//
//  Created by Balázs Kilvády on 02/15/21.
//

import Foundation

protocol CppConvertibleType: AnyObject {
    var _cppObject: OpaquePointer { get }
    #if DEBUG
        var _baseAddress: UnsafeMutableRawPointer { get }
    #endif
}

extension CppConvertibleType {
    #if DEBUG
        var _baseAddress: UnsafeMutableRawPointer {
            Unmanaged.passUnretained(self).toOpaque()
        }
    #endif
}
