//
//  CartItemRow.swift
//  DCPizza
//
//  Created by Balázs Kilvády on 7/6/20.
//  Copyright © 2020 kil-dev. All rights reserved.
//

import SwiftUI
import Domain

struct CartItemRow: View {
    let viewModel: CartItemRowViewModel

    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: "xmark")
                .foregroundColor(KColors.cTint)
                .font(.system(size: 10, weight: .bold))
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

#if DEBUG
    struct CartItemRow_Previews: PreviewProvider {
        static var previews: some View {
            CartItemRow(
                viewModel: CartItemRowViewModel(
                    item: CartItem(name: "Name", price: 5.0, id: 0),
                    index: 0
                ))
                .previewLayout(.fixed(width: 375, height: 44))
        }
    }
#endif
