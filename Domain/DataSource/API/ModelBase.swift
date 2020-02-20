//
//  ModelBase.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/18/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

protocol EntityModel: Decodable {
    init()
}

extension Array: EntityModel where Element: Decodable {}

struct ModelBase<Entity: EntityModel>: ModelProtocol {
    typealias Result = Entity

    init() {}

    func process(json: Data) throws -> Result {
        // DLog("Recved json data:\n", json)

        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(Result.self, from: json)
            return object
        } catch {
            DLog("Decoding error: ", error)
        }
        return Result()
    }
}
