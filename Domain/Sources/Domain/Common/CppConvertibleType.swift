//
//  CppConvertibleType.swift
//  Domain
//
//  Created by Balázs Kilvády on 02/15/21.
//

import Foundation

protocol CppConvertibleType: AnyObject {
    associatedtype CppPointer
    var _cppObject: CppPointer { get }
    #if DEBUG
        var _baseAddress: UnsafeMutableRawPointer { get }
    #endif

    init(cppObject: CppPointer)
}

extension CppConvertibleType {
    #if DEBUG
        var _baseAddress: UnsafeMutableRawPointer {
            Unmanaged.passUnretained(self).toOpaque()
        }
    #endif
}
