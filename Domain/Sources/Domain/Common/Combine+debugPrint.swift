//
//  Combine+debugPrint.swift
//
//
//  Created by Balázs Kilvády on 7/20/20.
//

import Combine

public extension Publisher {
    /// Prints log messages for all publishing events.
    ///
    /// - Parameter prefix: A string with which to prefix all log messages. Defaults to an empty string.
    /// - Returns: A publisher that prints log messages for all publishing events.
    func debug(_ prefix: String = "", file: String = #file, line: Int = #line) -> Publishers.Print<Self> {
        print("<\(file.lastPathComponent):\(line)> \(prefix)")
    }
}
