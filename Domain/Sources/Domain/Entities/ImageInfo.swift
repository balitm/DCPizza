//
//  ImageInfo.swift
//  Domain
//
//  Created by Balázs Kilvády on 05/14/21.
//

import Foundation

public struct ImageInfo {
    let url: URL
    let offset: Int

    public init(url: URL, offset: Int) {
        self.url = url
        self.offset = offset
    }
}
