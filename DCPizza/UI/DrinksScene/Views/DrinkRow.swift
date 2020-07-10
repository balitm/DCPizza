//
//  DrinkRow.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 7/10/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI

struct DrinkRow: View {
    let viewModel: DrinkRowViewModel

    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "plus")
                .foregroundColor(KColors.cTint)
                .font(.system(size: 11, weight: .regular))
                .frame(width: 54)
            Text(viewModel.name)
                .foregroundColor(KColors.textColor)
            Spacer()
            Text(viewModel.priceText)
                .foregroundColor(KColors.textColor)
            Spacer()
                .frame(width: 12)
        }
        .frame(height: 44)
    }
}

struct DrinkRow_Previews: PreviewProvider {
    static var previews: some View {
        DrinkRow(viewModel: DrinkRowViewModel(
            name: "Cola",
            priceText: "$0.5",
            index: 0
        ))
            .previewLayout(.fixed(width: 375, height: 44))
    }
}
