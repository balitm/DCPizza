//
//  ImageInfo.swift
//  Domain
//
//  Created by Balázs Kilvády on 05/14/21.
//

import Foundation

public struct ImageInfo {
    public static let empty = ImageInfo(url: URL(string: "https://kildev.hu")!, offset: -1)

    let url: URL
    let offset: Int

    public init(url: URL, offset: Int) {
        self.url = url
        self.offset = offset
    }
}

extension ImageInfo: Equatable {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        lhs.offset == rhs.offset
    }
}
