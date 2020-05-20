//
//  Array+extension.swift
//  Domain
//
//  Created by Balázs Kilvády on 5/20/20.
//

import Foundation

extension Array {
    func element(at index: Int) throws -> Element {
        guard index < count && index >= 0 else {
            throw API.ErrorType.disabled
        }
        return self[index]
    }
}
