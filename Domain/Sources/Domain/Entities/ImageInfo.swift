//
//  ImageInfo.swift
//  Domain
//
//  Created by Balázs Kilvády on 05/14/21.
//

import Foundation
import class AlamofireImage.Image

public struct ImageInfo {
    let image: Image?
    let url: URL?
    let offset: Int
}
