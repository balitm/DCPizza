//
//  DatabaseContainerProtocol.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/24/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

protocol DatabaseContainerProtocol {}

extension DatabaseContainerProtocol {
    static func initContainer() -> DS.Container? {
        DS.dbQueue.sync {
            do {
                return try DS.Container()
            } catch {
                DLog("# DB init failed: ", error)
            }
            return nil
        }
    }
}
