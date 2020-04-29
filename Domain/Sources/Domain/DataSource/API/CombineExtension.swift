//
//  File.swift
//  
//
//  Created by Balázs Kilvády on 4/24/20.
//

import Foundation

public struct Combinable<Base> {
    /// Base object to extend.
    public let base: Base

    /// Creates extensions with base object.
    ///
    /// - parameter base: Base object.
    public init(_ base: Base) {
        self.base = base
    }
}

/// A type that has Combinable extensions.
public protocol CombineCompatible {
    /// Extended type
    associatedtype CombinableBase

    /// Combinable extensions.
    static var cmb: Combinable<CombinableBase>.Type { get set }

    /// Combinable extensions.
    var cmb: Combinable<CombinableBase> { get set }
}

extension CombineCompatible {
    /// Combinable extensions.
    public static var cmb: Combinable<Self>.Type {
        get {
            return Combinable<Self>.self
        }
        set {
            // this enables using Combinable to "mutate" base type
        }
    }

    /// Combinable extensions.
    public var cmb: Combinable<Self> {
        get {
            return Combinable(self)
        }
        set {
            // this enables using Combinable to "mutate" base object
        }
    }
}
