//
//  DatabaseContainerProtocol.swift
//  Domain
//
//  Created by Balázs Kilvády on 2/24/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import Foundation

protocol DatabaseContainerProtocol {
    var container: DS.Container? { get }
}

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

    func execute(_ block: (DS.Container) throws -> Void) {
        guard let container = container else {
            DLog("# No usable DB container.")
            return
        }
        do {
            try block(container)
        } catch {
            DLog("# DB operation failed.")
        }
    }
}
