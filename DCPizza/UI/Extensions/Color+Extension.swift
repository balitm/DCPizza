//
//  Color+Extension.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 6/8/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI

extension Color {
    init(hex: Int) {
        let red = (hex & 0xff0000) >> 16
        let green = (hex & 0xff00) >> 8
        let blue = hex & 0xff
        let max = 255.0

        self.init(red: Double(red) / max,
                  green: Double(green) / max,
                  blue: Double(blue) / max)
    }
}
