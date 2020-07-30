//
//  CartTotalRow.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 7/6/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI

struct CartTotalRow: View {
    let viewModel: CartTotalRowViewModel

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(width: 54)
            Text("TOTAL")
                .foregroundColor(KColors.textColor)
                .fontWeight(.bold)
            Spacer()
            Text(viewModel.priceText)
                .foregroundColor(KColors.textColor)
                .fontWeight(.bold)
            Spacer()
                .frame(width: 12)
        }
        .frame(height: 44)
    }
}

struct CartTotalRow_Previews: PreviewProvider {
    static var previews: some View {
        CartTotalRow(viewModel: CartTotalRowViewModel(price: 12.5))
            .previewLayout(.fixed(width: 375, height: 44))
    }
}
